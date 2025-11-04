//
//  ContentView.swift
//  SOQLFormatter
//
//  Created by Andrew Mugford on 2025-11-04.
//

import SwiftUI
import AppKit

struct SavedQuery: Identifiable, Codable {
    let id: UUID
    var name: String
    var query: String
}

struct ContentView: View {
    @State private var savedQueries: [SavedQuery] = []
    @State private var selectedQueryIndex = 0
    @State private var currentQuery = ""
    @State private var newQueryName = ""
    @State private var variableInput = ""
    @State private var formattedQuery = ""
    @State private var showDeleteConfirmation = false
    @State private var showCopiedAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // App title
            Text("SOQLFormatter created by Andrew Mugford. Open Source.")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top)
            
            Divider()
            
            // Picker for saved queries
            HStack {
                Picker("Saved Query", selection: $selectedQueryIndex) {
                    ForEach(0..<savedQueries.count, id: \.self) { index in
                        Text(savedQueries[index].name)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedQueryIndex) {
                    if savedQueries.indices.contains(selectedQueryIndex) {
                        currentQuery = savedQueries[selectedQueryIndex].query
                    }
                }
                
                Button("Delete") {
                    showDeleteConfirmation = true
                }
                .disabled(savedQueries.isEmpty)
                .alert("Delete Query?", isPresented: $showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        deleteSelectedQuery()
                    }
                } message: {
                    if savedQueries.indices.contains(selectedQueryIndex) {
                        Text("Are you sure you want to delete '\(savedQueries[selectedQueryIndex].name)'?")
                    } else {
                        Text("Are you sure you want to delete this query?")
                    }
                }
            }
            .padding(.horizontal)
            
            // Add / Update query controls
            HStack {
                TextField("New Query Name", text: $newQueryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 250)
                
                Button("Add New") {
                    guard !newQueryName.isEmpty else { return }
                    let newQuery = SavedQuery(id: UUID(), name: newQueryName, query: currentQuery)
                    savedQueries.append(newQuery)
                    selectedQueryIndex = savedQueries.count - 1
                    newQueryName = ""
                    saveQueries()
                }
                
                Button("Update Current") {
                    if savedQueries.indices.contains(selectedQueryIndex) {
                        savedQueries[selectedQueryIndex].query = currentQuery
                        saveQueries()
                    }
                }
                .disabled(savedQueries.isEmpty)
            }
            .padding(.horizontal)
            
            // SOQL template editor
            Text("SOQL Template:")
                .font(.headline)
                .padding(.horizontal)
            TextEditor(text: $currentQuery)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 120)
                .border(Color.gray.opacity(0.3))
                .padding(.horizontal)
            
            // Variable input section
            Text("Paste in variable (such as email address or ID). One per line or comma separated:")
                .font(.headline)
                .padding(.horizontal)
            TextEditor(text: $variableInput)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 120)
                .border(Color.gray.opacity(0.3))
                .padding(.horizontal)
            
            // Format button
            HStack {
                Spacer()
                Button("Format SOQL") {
                    formattedQuery = formatVariablesIntoSOQL(template: currentQuery, values: variableInput)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            // Formatted query output
            Text("Formatted Query:")
                .font(.headline)
                .padding(.horizontal)
            TextEditor(text: $formattedQuery)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 200)
                .border(Color.gray.opacity(0.3))
                .padding(.horizontal)
            
            // Copy to clipboard button
            HStack {
                Spacer()
                Button("Copy to Clipboard") {
                    copyToClipboard(formattedQuery)
                    showCopiedAlert = true
                }
                .disabled(formattedQuery.isEmpty)
                Spacer()
            }
            .padding(.bottom)
            .alert("Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The formatted SOQL query has been copied to your clipboard.")
            }
            
            Spacer()
        }
        .onAppear {
            savedQueries = loadQueries()
            if !savedQueries.isEmpty {
                currentQuery = savedQueries[selectedQueryIndex].query
            }
        }
        .padding()
        .frame(minWidth: 700, minHeight: 800)
    }
    
    // MARK: - Delete helper
    func deleteSelectedQuery() {
        if savedQueries.indices.contains(selectedQueryIndex) {
            savedQueries.remove(at: selectedQueryIndex)
            saveQueries()
            if savedQueries.isEmpty {
                currentQuery = ""
            } else {
                selectedQueryIndex = 0
                currentQuery = savedQueries[0].query
            }
        }
    }
    
    // MARK: - Formatting logic
    func formatVariablesIntoSOQL(template: String, values: String) -> String {
        let cleaned = values
            .replacingOccurrences(of: "\r\n", with: ",")
            .replacingOccurrences(of: "\r", with: ",")
            .replacingOccurrences(of: "\n", with: ",")
            .replacingOccurrences(of: " ", with: "")
        
        let parts = cleaned
            .split(separator: ",")
            .filter { !$0.isEmpty }
            .map { "'\($0)'" }
        
        let grouped = parts.enumerated().map { index, value in
            index % 10 == 9 ? "\(value),\n" : "\(value), "
        }.joined()
        
        let finalList = grouped.trimmingCharacters(in: CharacterSet(charactersIn: ", \n"))
        
        if template.contains("{variable}") {
            return template.replacingOccurrences(of: "{variable}", with: finalList)
        }
        
        if template.range(of: "WHERE", options: .caseInsensitive) != nil {
            return template + " AND Id IN (\(finalList))"
        } else {
            return template + " WHERE Id IN (\(finalList))"
        }
    }
    
    // MARK: - Clipboard helper
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    // MARK: - Persistence
    func saveQueries() {
        if let data = try? JSONEncoder().encode(savedQueries) {
            UserDefaults.standard.set(data, forKey: "savedQueries")
        }
    }
    
    func loadQueries() -> [SavedQuery] {
        if let data = UserDefaults.standard.data(forKey: "savedQueries"),
           let decoded = try? JSONDecoder().decode([SavedQuery].self, from: data) {
            return decoded
        } else {
            // Default starter queries
            return [
                SavedQuery(id: UUID(), name: "Contacts by Email", query: "SELECT Id, Name, Email FROM Contact WHERE Email IN ({variable})"),
                SavedQuery(id: UUID(), name: "Leads by ID", query: "SELECT Id, Name, Company FROM Lead WHERE Id IN ({variable})")
            ]
        }
    }
}

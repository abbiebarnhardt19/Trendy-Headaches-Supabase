//
//  Profile Components.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//
 
import SwiftUI

//add, edit, and drop list
struct EditableList: View {
    @Binding var items: [String]
    var title, bg, accent: String
    var requiresReason: Bool = false
    var onAdd: (String) -> Void
    var onEdit: (String, String) -> Void
    var onDelete: (_ name: String, _ reason: String?) -> Void

    let width = UIScreen.main.bounds.width / 2 - 15
    let rowHeight: CGFloat = 50

    @State private var newItemText = ""
    @State private var editingIndex: Int? = nil
    @State private var originalValue = ""
    @State private var showDeleteConfirmation = false
    @State private var itemToDelete: String? = nil
    @State private var medEndReason: String = ""

    var body: some View {
        VStack(spacing: 0) {
            //go through and do all the items
            ForEach(items.indices.filter { items[$0] != "None entered" }, id: \.self) { i in
                itemRow(index: i)
            }
            //extra from for new item
            addNewItemRow
        }
        //for medications, ask why stop
        .alert(
            requiresReason ? "Please list a reason for stopping this medication" : "Are you sure you want to delete this item?",
            isPresented: $showDeleteConfirmation,
            presenting: itemToDelete
        ) { item in
            if requiresReason {
                TextField("Enter reason", text: $medEndReason)
                Button("Submit", role: .destructive) {
                    onDelete(item, medEndReason)
                    items.removeAll { $0 == item }
                    medEndReason = ""
                }
                Button("Cancel", role: .cancel) {
                    medEndReason = ""
                }
            } else {
                Button("Delete", role: .destructive) {
                    onDelete(item, "")
                    items.removeAll { $0 == item }
                }
                Button("Cancel", role: .cancel) {}
            }
        } message: { item in
            if !requiresReason {
                Text("This will mark '\(item)' as inactive.")
            }
        }

        .frame(width: width,
               height: CGFloat(items.indices.filter { items[$0] != "None entered" }.count + 1) * rowHeight)
        .padding(.bottom, 5)
    }

    //text field for each item
    @ViewBuilder
    private func itemRow(index i: Int) -> some View {
        let item = items[i]
        ZStack(alignment: .trailing) {
            //field with current value, can edit
            TextField("", text: editingIndex == i ? $items[i] : .constant(item))
                .padding(.vertical, 10)
                .padding(.trailing, 90)
                .padding(.leading, 10)
                .background(Color(hex: accent))
                .foregroundColor(Color(hex: bg))
                .cornerRadius(8)
                .font(.system(size: 20, design: .serif))
                .frame(height: rowHeight)
                .disabled(editingIndex != i ? true : false)

            HStack {
                //button to save edited value
                if editingIndex == i {
                    actionButton(systemName: "checkmark.circle.fill") {
                        if items[i] != originalValue { onEdit(originalValue, items[i]) }
                        editingIndex = nil
                    }
                    //button to edit value
                } else {
                    actionButton(systemName: "pencil.circle.fill") {
                        originalValue = items[i]
                        editingIndex = i
                    }
                }
                //button to end value
                actionButton(systemName: "minus.circle.fill") {
                    itemToDelete = items[i]
                    showDeleteConfirmation = true
                }
            }
            .padding(.trailing, 8)
        }
    }

    //different text field and button for adding item
    private var addNewItemRow: some View {
        HStack {
            ZStack(alignment: .trailing) {
                ZStack(alignment: .leading) {
                    if newItemText.isEmpty {
                        CustomText(text: "New item", color: bg, textSize: 20)
                            .padding(.leading, 10)
                            .padding(.vertical, 10)
                    }
                    TextField("", text: $newItemText)
                        .padding(.vertical, 10)
                        .padding(.leading, 10)
                        .padding(.trailing, 35)
                        .font(.system(size: 20, design: .serif))
                        .foregroundColor(Color(hex: bg))
                        .background(Color.clear)
                        .cornerRadius(8)
                }
                .background(Color(hex: accent))
                .cornerRadius(8)
                .frame(height: rowHeight)
                
                //add the new value to the db
                Button {
                    let trimmed = newItemText.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    items.append(trimmed)
                    onAdd(trimmed)
                    newItemText = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: bg))
                        .padding(.trailing, 8)
                        .font(.system(size: 28))
                }
                .buttonStyle(.plain)
                .disabled(newItemText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func actionButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundColor(Color(hex: bg))
                .font(.system(size: 28))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//button that produces more buttons
struct FloatButton: View {
    var accent: String
    var bg: String
    var options: [String]
    var actions: [() -> Void]
    
    //position values
    let xList: [CGFloat] = [-20, -100, -100, -20]
    let yList: [CGFloat] = [-90, -40, 10, 60]
    
    @State private var showMenu = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            //initial button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showMenu.toggle()
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 40, design: .serif))
                    .padding(20)
                    .background(Color(hex: accent))
                    .foregroundColor(Color(hex: bg))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            //show the options
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showMenu = false
                        if index < actions.count {
                            actions[index]()
                        }
                    }
                } label: {
                    Text(option)
                        .frame(width: 140, height: 40)
                        .background(Color(hex: accent))
                        .foregroundColor(Color(hex: bg))
                        .font(.system(size: 15, design: .serif))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(hex: bg), lineWidth: 2))
                        .opacity(showMenu ? 1 : 0)
                        .scaleEffect(showMenu ? 1 : 0.5)
                }
                .buttonStyle(.plain)
                .offset(x: xList[index], y: yList[index])
            }
        }
    }
}

struct EditableSection: View {
    let title: String
    @Binding var items: [String]
    let table: String
    let requiresReason: Bool
    var medCat: String? = nil
    
    // styling bindings
    let bg: String
    let accent: String
    let colWidth: CGFloat
    let userID: Int64
    
    @EnvironmentObject var preloadManager: PreloadManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            SectionTitle(title: title, width: colWidth, color: accent)
            
            EditableList(
                items: $items,
                title: title,
                bg: bg,
                accent: accent,
                requiresReason: requiresReason,
                onAdd: { newValue in
                    Task {
                        await Database.shared.insertItem(
                            tableName: table,
                            userID: userID,
                            name: newValue.capitalized,
                            medCat: medCat
                        )
                        await preloadManager.preloadAll(userID: userID)
                        
                    }
                },
                onEdit: { oldValue, newValue in
                    Task {
                        await Database.shared.updateItem(
                            tableName: table,
                            userID: userID,
                            old: oldValue,
                            new: newValue.capitalized,
                            medCat: medCat
                        )
                        await preloadManager.preloadAll(userID: userID)
                    }
                },
                onDelete: { value, reason in
                    Task {
                        await Database.shared.endItem(
                            tableName: table,
                            userID: userID,
                            name: value,
                            medCat: medCat,
                            endReason: reason
                        )
                        await preloadManager.preloadAll(userID: userID)

                    }
                }
            )
        }
    }
}

struct SectionTitle: View {
    let title: String
    let width: CGFloat
    let color: String
    
    var body: some View {
        CustomText(
            text: title,
            color: color,
            width: width - 15,
            textAlign: .center,
            multiAlign: .center,
            bold: true
        )
    }
}

struct SectionList: View {
    let colTitle: String
    let items: [String]
    let width: CGFloat
    let color: String
    
    var body: some View {
        VStack {
            SectionTitle(title: colTitle, width: width, color: color)
            CustomList(items: items, color: color)
        }
    }
}





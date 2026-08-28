import SwiftUI
import UniformTypeIdentifiers

public struct ContentView: View {
    
    @StateObject private var viewModel = ProgrammerViewModel()
    @State private var showingFilePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        headerView
                        
                        boardSelectionCard
                        
                        hexFileCard
                        
                        connectionCard
                        
                        programmingCard
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Arduino Programmer")
            .navigationBarTitleDisplayMode(.large)
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [UTType(filenameExtension: "hex")!],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
            .alert("Bilgi", isPresented: $showingAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "cpu.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Arduino Programmer")
                .font(.title)
                .fontWeight(.bold)
            
            Text("iOS üzerinden Arduino'ya yazılım yükleyin")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    private var boardSelectionCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Kart Seçimi", systemImage: "rectangle.on.rectangle")
                .font(.headline)
                .foregroundColor(.primary)
            
            Picker("Kart Tipi", selection: $viewModel.selectedBoardType) {
                ForEach(ArduinoBoardType.allCases) { boardType in
                    Text(boardType.rawValue).tag(boardType)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Çip: \(viewModel.selectedBoardType.chipset)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Flash: \(viewModel.selectedBoardType.flashSize / 1024) KB")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Baud: \(viewModel.selectedBoardType.baudRate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Sayfa: \(viewModel.selectedBoardType.pageSize) byte")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var hexFileCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Hex Dosyası", systemImage: "doc.fill")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let hexFile = viewModel.selectedHexFile {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading) {
                        Text(hexFile.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(hexFile.data.count) bytes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.selectedHexFile = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
            } else {
                Button(action: {
                    showingFilePicker = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Hex Dosyası Seç")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var connectionCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Bağlantı", systemImage: "antenna.radiowaves.left.and.right")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 15) {
                Button(action: {
                    Task {
                        await viewModel.connectBluetooth()
                    }
                }) {
                    VStack {
                        Image(systemName: "bluetooth")
                            .font(.title2)
                        Text("Bluetooth")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isConnected ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isConnected || viewModel.status.isInProgress)
            }
            
            if viewModel.isConnected {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Bağlantı kuruldu")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await viewModel.disconnect()
                        }
                    }) {
                        Text("Bağlantıyı Kes")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var programmingCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Programlama", systemImage: "arrow.down.circle.fill")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: statusIcon)
                        .foregroundColor(statusColor)
                    Text(viewModel.status.description)
                        .font(.subheadline)
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                
                if viewModel.status.isInProgress {
                    ProgressView(value: viewModel.progress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal)
                }
                
                Button(action: {
                    Task {
                        await uploadFirmware()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.down.doc.fill")
                        Text("Yazılımı Yükle")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canUpload ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!canUpload)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var canUpload: Bool {
        viewModel.isConnected && 
        viewModel.selectedHexFile != nil && 
        !viewModel.status.isInProgress
    }
    
    private var statusIcon: String {
        switch viewModel.status {
        case .idle:
            return "circle"
        case .connecting, .verifying:
            return "arrow.triangle.2.circlepath"
        case .connected:
            return "checkmark.circle.fill"
        case .erasing, .programming, .verifyingFlash:
            return "arrow.down.circle.fill"
        case .completed:
            return "checkmark.circle.fill"
        case .failed:
            return "xmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch viewModel.status {
        case .idle:
            return .gray
        case .connecting, .verifying, .erasing, .programming, .verifyingFlash:
            return .blue
        case .connected, .completed:
            return .green
        case .failed:
            return .red
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let data = try Data(contentsOf: url)
                let hexFile = HexFile(
                    name: url.lastPathComponent,
                    url: url,
                    data: data
                )
                viewModel.selectedHexFile = hexFile
            } catch {
                alertMessage = "Dosya okunamadı: \(error.localizedDescription)"
                showingAlert = true
            }
            
        case .failure(let error):
            alertMessage = "Dosya seçilemedi: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func uploadFirmware() async {
        do {
            try await viewModel.uploadFirmware()
            alertMessage = "Yazılım başarıyla yüklendi!"
            showingAlert = true
        } catch {
            alertMessage = "Hata: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

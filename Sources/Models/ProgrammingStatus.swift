import Foundation

public enum ProgrammingStatus: Equatable {
    case idle
    case connecting
    case connected
    case verifying
    case erasing
    case programming(progress: Double)
    case verifyingFlash(progress: Double)
    case completed
    case failed(error: String)
    
    public var description: String {
        switch self {
        case .idle:
            return "Hazır"
        case .connecting:
            return "Bağlanıyor..."
        case .connected:
            return "Bağlandı"
        case .verifying:
            return "Doğrulanıyor..."
        case .erasing:
            return "Siliniyor..."
        case .programming(let progress):
            return "Yazılım yükleniyor... \(Int(progress * 100))%"
        case .verifyingFlash(let progress):
            return "Doğrulanıyor... \(Int(progress * 100))%"
        case .completed:
            return "Tamamlandı!"
        case .failed(let error):
            return "Hata: \(error)"
        }
    }
    
    public var isInProgress: Bool {
        switch self {
        case .idle, .completed, .failed:
            return false
        default:
            return true
        }
    }
}

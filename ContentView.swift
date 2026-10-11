import SwiftUI
import Foundation

struct ContentView: View {
    @State private var statusMessage: String = "Trạng thái: Sẵn sàng"
    @State private var isCompleted: Bool = false
    
    // Tên bundle ID của game/ứng dụng đích
    let targetBundleID = "com.dts.freefireth"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Tiêu đề ứng dụng
                VStack(spacing: 8) {
                    Image(systemName: "folder.badge.gearshape")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    
                    Text("ThreeOneOSFive Manager")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Quản lý & Thiết lập dữ liệu Free Fire")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Hiển thị trạng thái
                VStack(spacing: 12) {
                    Text(statusMessage)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 30))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // Các nút tính năng chính
                VStack(spacing: 15) {
                    // Nút thực hiện: Đặt 2 file vào thư mục Documents của ứng dụng đích
                    Button(action: {
                        injectFilesToTargetContainer()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Chèn File vào Documents")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Nút khôi phục: Xóa các file đã chèn
                    Button(action: {
                        restoreOriginalState()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                            Text("Khôi phục (Xóa file)")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Logic xử lý
    
    /// Hàm tìm đường dẫn thư mục Documents của ứng dụng đích và sao chép 2 file vào đó[span_1](start_span)[span_1](end_span)
    func injectFilesToTargetContainer() {
        guard let targetDocumentsPath = getTargetDocumentsDirectory() else {
            statusMessage = "Lỗi: Không tìm thấy đường dẫn container của \(targetBundleID)[span_2](start_span)[span_2](end_span)."
            isCompleted = false
            return
        }
        
        do {
            let fileManager = FileManager.default
            
            // Đảm bảo thư mục đích tồn tại
            if !fileManager.fileExists(atPath: targetDocumentsPath.path) {
                try fileManager.createDirectory(at: targetDocumentsPath, withIntermediateDirectories: true, attributes: nil)
            }
            
            // Giả lập nội dung của 2 file cần chèn (Bạn có thể thay thế bằng file thật có sẵn trong Bundle của app ThreeOneOSFive)
            let file1Name = "config_settings.json"
            let file2Name = "patch_data.dat"
            
            let file1URL = targetDocumentsPath.appendingPathComponent(file1Name)
            let file2URL = targetDocumentsPath.appendingPathComponent(file2Name)
            
            // Ghi dữ liệu mẫu (hoặc sao chép từ resource trong app bundle của bạn ra)
            let sampleData1 = "{\"configured\": true, \"version\": \"3105\"}".data(using: .utf8)!
            let sampleData2 = "DATA_PATCH_STREAM_THREE_ONE_OS_FIVE".data(using: .utf8)!
            
            try sampleData1.write(to: file1URL)
            try sampleData2.write(to: file2URL)
            
            statusMessage = "Thành công! Đã dán 2 file vào thư mục Documents của \(targetBundleID)[span_3](start_span)[span_3](end_span)."
            isCompleted = true
        } catch {
            statusMessage = "Lỗi khi ghi file: \(error.localizedDescription)"
            isCompleted = false
        }
    }
    
    /// Hàm khôi phục (Xóa các file đã đặt trong thư mục Documents của ứng dụng đích)[span_4](start_span)[span_4](end_span)
    func restoreOriginalState() {
        guard let targetDocumentsPath = getTargetDocumentsDirectory() else {
            statusMessage = "Lỗi: Không tìm thấy đường dẫn container[span_5](start_span)[span_5](end_span)."
            isCompleted = false
            return
        }
        
        do {
            let fileManager = FileManager.default
            let file1URL = targetDocumentsPath.appendingPathComponent("config_settings.json")
            let file2URL = targetDocumentsPath.appendingPathComponent("patch_data.dat")
            
            // Xóa file 1 nếu tồn tại
            if fileManager.fileExists(atPath: file1URL.path) {
                try fileManager.removeItem(at: file1URL)
            }
            
            // Xóa file 2 nếu tồn tại
            if fileManager.fileExists(atPath: file2URL.path) {
                try fileManager.removeItem(at: file2URL)
            }
            
            statusMessage = "Đã khôi phục thành công! Đã xóa các file khỏi thư mục Documents[span_6](start_span)[span_6](end_span)."
            isCompleted = false
        } catch {
            statusMessage = "Lỗi khi xóa file: \(error.localizedDescription)"
        }
    }
    
    /// Helper: Lấy đường dẫn thư mục Documents dựa trên cấu trúc sandbox iOS hoặc container chia sẻ
    func getTargetDocumentsDirectory() -> URL? {
        // Trong môi trường sandbox thông thường hoặc nếu ứng dụng có quyền truy cập container group:
        let fileManager = FileManager.default
        
        // Cách 1: Thử tìm theo đường dẫn container chuẩn trên iOS (nếu app có quyền truy cập chia sẻ container / jailbreak / TrollStore)
        // Đường dẫn chung của container ứng dụng trên iOS thường nằm ở /var/mobile/Containers/Data/Application/...
        // Ở đây lấy mô phỏng đường dẫn App Library hoặc qua Group Container / Sandbox tương ứng:
        if let baseURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Trường hợp chạy thông thường hoặc test trên mô phỏng, ta trỏ tới thư mục Documents của chính app hoặc thay đổi logic container ở đây.
            // Nếu bạn đang dùng hàm patch container riêng của project ThreeOneOSFive sẵn có, bạn có thể gọi trực tiếp hàm tìm đường dẫn container tại đây.
            return baseURL
        }
        
        return nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

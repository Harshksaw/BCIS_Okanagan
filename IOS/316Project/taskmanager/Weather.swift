import SwiftUI
import CoreLocation
import SwiftUI

// Extension to add hex color initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
struct WeatherView: View {
    @State private var weatherData: WeatherData?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var locationManager = LocationManager()
    @State private var city = "Loading..."
    
    // Weather backgrounds based on conditions
    let weatherBackgrounds: [String: [Color]] = [
        "Clear": [Color.blue, Color(hex: "87CEEB")],
        "Clouds": [Color(hex: "708090"), Color(hex: "B0C4DE")],
        "Rain": [Color(hex: "4682B4"), Color(hex: "778899")],
        "Snow": [Color.white, Color(hex: "F0F8FF")],
        "Thunderstorm": [Color(hex: "4B0082"), Color(hex: "483D8B")],
        "Drizzle": [Color(hex: "6495ED"), Color(hex: "B0E0E6")],
        "Mist": [Color(hex: "DCDCDC"), Color(hex: "D3D3D3")],
        "Default": [Color.blue, Color(hex: "87CEEB")]
    ]
    
    var body: some View {
        ZStack {
            // Dynamic background based on weather
            LinearGradient(
                gradient: Gradient(colors: backgroundColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack {
                if isLoading {
                    loadingView
                } else if let errorMessage = errorMessage {
                    errorView(message: errorMessage)
                } else if let weather = weatherData {
                    weatherContentView(weather: weather)
                }
            }
            .padding()
        }
        .onAppear {
            setupLocationManager()
            requestLocation()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Fetching weather data...")
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.white)
            
            Text("Weather Error")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.8))
            
            Button(action: {
                isLoading = true
                errorMessage = nil
                requestLocation()
            }) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.3))
                    )
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func weatherContentView(weather: WeatherData) -> some View {
        VStack(spacing: 25) {
            // Location and time
            VStack(spacing: 5) {
                Text(city)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Weather icon and temperature
            HStack(alignment: .center, spacing: 15) {
                weatherIcon(condition: weather.weather.first?.main ?? "Clear")
                    .font(.system(size: 70))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading) {
                    Text("\(Int(weather.main.temp))°C")
                        .font(.system(size: 45, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(weather.weather.first?.description.capitalized ?? "")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(.vertical, 20)
            
            // Weather details
            HStack(spacing: 30) {
                WeatherDetailItem(icon: "humidity.fill", value: "\(Int(weather.main.humidity))%", label: "Humidity")
                
                WeatherDetailItem(icon: "wind", value: "\(Int(weather.wind.speed)) m/s", label: "Wind")
                
                WeatherDetailItem(icon: "thermometer.medium", value: "\(Int(weather.main.feels_like))°", label: "Feels like")
            }
            .padding(.horizontal)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.2))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            
            // Min and max temperature
            HStack(spacing: 40) {
                VStack {
                    Text("Min")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(Int(weather.main.temp_min))°")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack {
                    Text("Max")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(Int(weather.main.temp_max))°")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.2))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            
            // Refresh button
            Button(action: {
                refreshWeather()
            }) {
                Label("Refresh", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.3))
                    )
            }
            .padding(.top, 10)
        }
    }
    
    // MARK: - Helper Views
    
    struct WeatherDetailItem: View {
        let icon: String
        let value: String
        let label: String
        
        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                
                Text(value)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var backgroundColors: [Color] {
        if let weather = weatherData, let condition = weather.weather.first?.main {
            return weatherBackgrounds[condition] ?? weatherBackgrounds["Default"]!
        }
        return weatherBackgrounds["Default"]!
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    private func weatherIcon(condition: String) -> Image {
        let conditionCode = weatherData?.weather.first?.id ?? 0
        
        // First check if we can get the icon directly from the API icon URL
        if let iconPath = weatherData?.weather.first?.icon, !iconPath.isEmpty {
            // WeatherAPI.com icons are full URLs or paths, we need to parse out day/night
            let isDay = (weatherData?.weather.first?.icon.contains("day") ?? false) || iconPath.contains("/day/")
            
            // The API provides full URLs, we won't be able to use them directly in SwiftUI
            // Instead, we'll match icon paths to SF Symbols based on condition codes
            if let code = weatherData?.weather.first?.id {
                return getIconBySFSymbol(conditionCode: code, isDay: isDay)
            }
        }
        
        // Fallback to our original logic based on condition text
        let time = Calendar.current.component(.hour, from: Date())
        let isDay = time >= 6 && time < 18
        
        switch condition {
        case "Clear":
            return Image(systemName: isDay ? "sun.max.fill" : "moon.stars.fill")
        case "Clouds":
            return Image(systemName: isDay ? "cloud.fill" : "cloud.moon.fill")
        case "Rain":
            return Image(systemName: "cloud.rain.fill")
        case "Snow":
            return Image(systemName: "snow")
        case "Thunderstorm":
            return Image(systemName: "cloud.bolt.fill")
        case "Drizzle":
            return Image(systemName: "cloud.drizzle.fill")
        case "Mist", "Fog", "Haze":
            return Image(systemName: "cloud.fog.fill")
        default:
            return Image(systemName: isDay ? "sun.max.fill" : "moon.stars.fill")
        }
    }
    
    private func getIconBySFSymbol(conditionCode: Int, isDay: Bool) -> Image {
        // Weather API condition codes mapped to SF Symbols
        switch conditionCode {
        case 1000: // Sunny / Clear
            return Image(systemName: isDay ? "sun.max.fill" : "moon.stars.fill")
        case 1003: // Partly Cloudy
            return Image(systemName: isDay ? "cloud.sun.fill" : "cloud.moon.fill")
        case 1006, 1009: // Cloudy, Overcast
            return Image(systemName: "cloud.fill")
        case 1030, 1135, 1147: // Mist, Fog
            return Image(systemName: "cloud.fog.fill")
        case 1063, 1150, 1153, 1180, 1183, 1240: // Light rain/drizzle
            return Image(systemName: "cloud.drizzle.fill")
        case 1186, 1189, 1192, 1195, 1243, 1246: // Moderate to heavy rain
            return Image(systemName: "cloud.rain.fill")
        case 1273, 1276, 1279, 1282: // Thunder
            return Image(systemName: "cloud.bolt.fill")
        case 1066, 1114, 1117, 1210, 1213, 1216, 1219, 1222, 1225, 1255, 1258: // Snow
            return Image(systemName: "snow")
        case 1069, 1072, 1168, 1171, 1198, 1201, 1204, 1207, 1237, 1249, 1252: // Sleet/freezing rain
            return Image(systemName: "cloud.sleet.fill")
        case 1087: // Thunder
            return Image(systemName: "cloud.bolt.fill")
        default:
            return Image(systemName: isDay ? "sun.max.fill" : "cloud.fill")
        }
    }
    
    // MARK: - Location
    
    private func setupLocationManager() {
        locationManager.requestAuthorization()
    }
    
    private func requestLocation() {
        isLoading = true
        errorMessage = nil
        
        locationManager.requestLocation { [self] result in
            switch result {
            case .success(let location):
                fetchCity(for: location)
                fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch error {
                    case .authorizationDenied:
                        self.errorMessage = "Location access denied. Please enable location services in Settings."
                    case .locationDisabled:
                        self.errorMessage = "Location services are disabled. Please enable them in Settings."
                    case .unableToFindLocation:
                        self.errorMessage = "Unable to determine your location. Please try again later."
                    case .unknown(let message):
                        self.errorMessage = "Location error: \(message)"
                    }
                }
            }
        }
    }
    
    private func fetchCity(for location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    return
                }
                
                if let placemark = placemarks?.first {
                    if let city = placemark.locality {
                        self.city = city
                    } else if let area = placemark.administrativeArea {
                        self.city = area
                    }
                }
            }
        }
    }
    
    // MARK: - API Call
    
    private func fetchWeather(latitude: Double, longitude: Double) {
        // WeatherAPI.com endpoint (replace with your own API key)
        let apiKey = "361e1a2ed546472189620731251004"
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(latitude),\(longitude)&aqi=no"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL configuration"
                self.isLoading = false
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No weather data received"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let weatherResponse = try decoder.decode(WeatherAPIResponse.self, from: data)
                    
                    // Convert WeatherAPI response to our model
                    self.weatherData = WeatherData(
                        weather: [
                            WeatherInfo(
                                id: Int(weatherResponse.current.condition.code),
                                main: self.mapConditionCodeToMain(weatherResponse.current.condition.code),
                                description: weatherResponse.current.condition.text,
                                icon: weatherResponse.current.condition.icon
                            )
                        ],
                        main: MainInfo(
                            temp: weatherResponse.current.temp_c,
                            feels_like: weatherResponse.current.feelslike_c,
                            temp_min: weatherResponse.current.temp_c - 2, // WeatherAPI doesn't provide min/max, estimate for display
                            temp_max: weatherResponse.current.temp_c + 2, // WeatherAPI doesn't provide min/max, estimate for display
                            pressure: Int(weatherResponse.current.pressure_mb),
                            humidity: Int(weatherResponse.current.humidity)
                        ),
                        wind: WindInfo(
                            speed: weatherResponse.current.wind_kph / 3.6, // Convert km/h to m/s
                            deg: Int(weatherResponse.current.wind_degree)
                        ),
                        name: weatherResponse.location.name
                    )
                    
                    // Set city from API response
                    if !weatherResponse.location.name.isEmpty {
                        self.city = weatherResponse.location.name
                    }
                    
                } catch {
                    print("JSON Decoding Error: \(error)")
                    self.errorMessage = "Unable to process weather data"
                }
            }
        }.resume()
    }
    
    // Map WeatherAPI condition codes to our weather categories
    private func mapConditionCodeToMain(_ code: Int) -> String {
        switch code {
        case 1000: // Sunny or Clear
            return "Clear"
        case 1003, 1006, 1009, 1030: // Partly cloudy, Cloudy, Overcast, Mist
            return "Clouds"
        case 1063, 1066, 1069, 1072, 1150, 1153, 1168, 1171: // Light rain or showers
            return "Drizzle"
        case 1180, 1183, 1186, 1189, 1192, 1195, 1198, 1201, 1240, 1243, 1246:
            return "Rain"
        case 1087, 1273, 1276, 1279, 1282: // Thundery outbreaks
            return "Thunderstorm"
        case 1066, 1114, 1117, 1210, 1213, 1216, 1219, 1222, 1225, 1255, 1258:
            return "Snow"
        case 1135, 1147: // Fog, Freezing fog
            return "Mist"
        default:
            return "Clear"
        }
    }
    
    private func refreshWeather() {
        isLoading = true
        errorMessage = nil
        requestLocation()
    }
}

// MARK: - Weather Data Models

// Original model retained for compatibility with UI
struct WeatherData: Codable {
    let weather: [WeatherInfo]
    let main: MainInfo
    let wind: WindInfo
    let name: String
}

struct WeatherInfo: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct MainInfo: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
    let humidity: Int
}

struct WindInfo: Codable {
    let speed: Double
    let deg: Int
}

// WeatherAPI.com specific models
struct WeatherAPIResponse: Codable {
    let location: LocationData
    let current: CurrentData
}

struct LocationData: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let localtime: String
}

struct CurrentData: Codable {
    let temp_c: Double
    let temp_f: Double
    let is_day: Int
    let condition: ConditionData
    let wind_mph: Double
    let wind_kph: Double
    let wind_degree: Int
    let wind_dir: String
    let pressure_mb: Double
    let pressure_in: Double
    let precip_mm: Double
    let precip_in: Double
    let humidity: Int
    let cloud: Int
    let feelslike_c: Double
    let feelslike_f: Double
    let vis_km: Double
    let vis_miles: Double
    let uv: Double
    let gust_mph: Double
    let gust_kph: Double
}

struct ConditionData: Codable {
    let text: String
    let icon: String
    let code: Int
}

// MARK: - Mock Data for Preview

let mockWeatherData = WeatherData(
    weather: [
        WeatherInfo(
            id: 1000,
            main: "Clear",
            description: "Sunny",
            icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
        )
    ],
    main: MainInfo(
        temp: 25.3,
        feels_like: 24.8,
        temp_min: 23.1,
        temp_max: 27.2,
        pressure: 1014,
        humidity: 58
    ),
    wind: WindInfo(
        speed: 3.6,
        deg: 160
    ),
    name: "New York"
)

// MARK: - Location Manager

enum LocationError: Error {
    case authorizationDenied
    case locationDisabled
    case unableToFindLocation
    case unknown(String)
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var locationCallback: ((Result<CLLocation, LocationError>) -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestLocation(completion: @escaping (Result<CLLocation, LocationError>) -> Void) {
        locationCallback = completion
        
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            completion(.failure(.authorizationDenied))
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        @unknown default:
            completion(.failure(.unknown("Unknown authorization status")))
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationCallback?(.success(location))
            locationCallback = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError {
            switch error.code {
            case .denied:
                locationCallback?(.failure(.authorizationDenied))
            case .locationUnknown:
                locationCallback?(.failure(.unableToFindLocation))
            default:
                locationCallback?(.failure(.unknown(error.localizedDescription)))
            }
        } else {
            locationCallback?(.failure(.unknown(error.localizedDescription)))
        }
        locationCallback = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            if let callback = locationCallback {
                manager.requestLocation()
            }
        case .denied, .restricted:
            locationCallback?(.failure(.authorizationDenied))
            locationCallback = nil
        case .notDetermined:
            // Wait for the user's decision
            break
        @unknown default:
            locationCallback?(.failure(.unknown("Unknown authorization status")))
            locationCallback = nil
        }
    }
}

// MARK: - Preview

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}

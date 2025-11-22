<div align="center">

# 📚 KMReader

<div>
  <img src="icon.svg" alt="KMReader Icon" width="128" height="128">
</div>

**A beautiful, native iOS client for [Komga](https://github.com/gotson/komga)**

*A media server for comics, mangas, BDs, and magazines*

[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org/)
[![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue.svg)](https://developer.apple.com/xcode/)

</div>

---

## ✨ Features

### 🔐 Authentication & Security

- **Secure Login**: User authentication with Komga server
- **Session Management**: Remember-me support with persistent sessions
- **Authentication Activity**: View login history and active sessions
- **Role-Based Access**: Support for admin and regular user roles

### 📚 Unified Browsing Experience

#### **Multi-Content Type Support**
- Browse **Series**, **Books**, **Collections**, and **Read Lists** in one unified view
- Quick content type switching with segmented picker
- Consistent interface across all content types

#### **Flexible Layout Options**
- **Grid View**: Customizable columns (1-8) for portrait and landscape orientations
- **List View**: Detailed list view with metadata
- Seamless layout switching via toolbar menu
- Preserve thumbnail aspect ratio option
- Show/hide card titles for cleaner interface

#### **Powerful Search & Filtering**
- Full-text search across all content types
- Library filtering available in all views
- Real-time search with debouncing
- Search history and suggestions

### 📖 Series Management

#### **Advanced Filtering**
- **Read Status**: All, Read, Unread, In Progress
- **Series Status**: All, Ongoing, Ended, Hiatus, Cancelled
- **Library Filter**: Filter by specific library

#### **Flexible Sorting**
- Sort by: Name, Date Added, Date Updated, Date Read, Release Date, Folder Name, Books Count, Random
- Sort direction: Ascending/Descending (except Random)
- Persistent sort preferences

#### **Rich Series Details**
- Complete metadata display:
  - Title, status, age rating, language
  - Publisher, authors, genres, tags
  - Summary and description
- Reading direction indicator
- Book count and reading progress
- Books list with:
  - Reading progress indicators
  - Sortable by book number (ascending/descending)
  - Quick access to reading

### 📗 Books Management

#### **Comprehensive Filtering & Sorting**
- Filter by read status (All, Read, Unread, In Progress)
- Sort by: Series, Name, Date Added, Date Updated, Release Date, Date Read, File Size, File Name, Page Count
- Sort direction: Ascending/Descending
- Grid and list layouts

#### **Book Details & Actions**
- Full metadata and reading progress display
- **Quick Actions**:
  - Add to Read List
  - Mark as read/unread
  - Analyze book
  - Refresh metadata
  - Delete book
  - Clear cache
- Direct reading from browse view
- Reading status indicators (UNREAD, IN_PROGRESS, READ)

### 📑 Collections & Read Lists

#### **Collections**
- Browse all collections with search and sort
- Grid and list layouts
- **Collection Details**:
  - Metadata (name, series count, dates, ordered status)
  - Browse series within collection
  - Delete collection

#### **Read Lists**
- Browse all read lists with search and sort
- Grid and list layouts
- **Read List Details**:
  - Metadata (name, book count, summary, dates, ordered status)
  - Browse books within read list
  - Direct reading from read list
  - Delete read list

### 📖 Advanced Reading Experience

#### **Multiple Reading Modes**
- **LTR (Left-to-Right)**: Horizontal page navigation for Western comics
- **RTL (Right-to-Left)**: Horizontal page navigation for manga
- **Vertical**: Vertical page scrolling mode
- **Webtoon**: Continuous vertical scroll with adjustable page width (50%-100%)
- Automatic reading direction detection from series metadata
- Manual reading mode selection during reading

#### **Rich Reader Features**
- **Zoom & Pan**:
  - Pinch to zoom (1x to 4x)
  - Double-tap to zoom
  - Drag to pan when zoomed
- **Navigation**:
  - Swipe/tap navigation between pages
  - Configurable tap zones for page navigation
  - Tap zone hints overlay (optional)
  - Page counter and progress slider
- **Controls**:
  - Auto-hide controls (3 seconds)
  - Reading direction picker
  - Background color selection (System, Black, White, Gray)
- **End Page**:
  - Beautiful end page view
  - Next book navigation
  - Return to series option
- **Save Pages**:
  - Save current page to Photos app
  - Save to Files app
  - Supported formats: JPEG, PNG, HEIF, WebP
  - Context menu on page images for quick save

#### **Progress Tracking**
- Automatic progress sync to server
- Resume from last read page
- Mark as read/unread
- Reading status indicators (UNREAD, IN_PROGRESS, READ)
- Progress bars and indicators throughout the app

### 📊 Dashboard

Your personalized reading hub with:

- **Keep Reading**: Books currently in progress (sorted by last read date)
- **On Deck**: Next books to read in series
- **Recently Added Books**: Latest additions to libraries
- **Recently Added Series**: New series added to libraries
- **Recently Updated Series**: Recently updated series
- Library filtering
- Pull to refresh
- Smooth animations and transitions

### 📜 Reading History

- Recently read books with relative timestamps
- Reading progress display for each book
- Library filtering
- Infinite scroll with automatic pagination
- Quick access to resume reading
- Clean, chronological view

### ⚙️ Comprehensive Settings

#### **Appearance**
- **Theme Color**: 12 beautiful color options with custom color picker
- **Browse Columns**: Adjustable columns (1-8) for portrait and landscape
- **Card Display**:
  - Show/hide series card titles
  - Show/hide book card series titles
  - Preserve thumbnail aspect ratio

#### **Reader**
- **Tap Zone**: Show/hide tap zone hints
- **Background**: Choose reader background color (System, Black, White, Gray)
- **Webtoon**: Adjustable page width (50% - 100%)

#### **Cache Management**
- View disk cache size and cached image count
- Adjust maximum disk cache size (512MB - 8GB, default 2GB)
- Clear disk cache manually
- Automatic cache cleanup when limit is exceeded

#### **Library Management**
- View all libraries
- Library scanning (regular and deep scan)
- Library metadata refresh
- Library deletion (admin only)
- Library statistics

#### **Server Information**
- Server version and build information
- Server capabilities
- Connection status

#### **Metrics**
- View server metrics and statistics
- Performance monitoring

#### **Account**
- User email and roles display
- Authentication activity log
- Secure logout

### 💾 Performance & Caching

#### **Two-Tier Image Caching System**
- **Disk Cache**: 
  - Persistent storage
  - Configurable size (default 2GB, range 512MB-8GB)
  - Automatic cleanup
- **Memory Cache**: 
  - Fast access (up to 50 images, 200MB)
  - LRU eviction policy

#### **Smart Image Loading**
- Load order: Memory cache → Disk cache → Network download
- Automatic downscaling of large images to prevent OOM
- Background image decoding
- WebP format support via SDWebImage
- Progressive image loading

#### **Intelligent Preloading**
- Page preloading based on reading mode (1-3 pages ahead)
- Thumbnail caching for fast browsing
- Optimized network requests

### 🛠️ Developer Features

#### **Comprehensive Logging**
- API request/response logging using Apple's unified logging system (OSLog)
- View logs in Xcode Console or Console.app
- Filter by process name: "Komga" or subsystem: "Komga"
- Category: "API"

**Log Format:**
```
📡 GET https://your-server.com/api/v2/users/me
✅ 200 GET https://your-server.com/api/v2/users/me (45.67ms)
```

**Log Symbols:**
- 📡 Request sent
- ✅ Successful response (200-299)
- ❌ Error response (400+) or network error
- 🔒 Unauthorized (401)
- ⚠️ Warning (e.g., empty response)
```

#### **Error Management**
- Comprehensive error handling
- User-friendly error messages
- Error notification system
- Copy error details to clipboard

---

## 🏗️ Architecture

Built with **SwiftUI** following **MVVM** (Model-View-ViewModel) pattern:

### **Models**
- Library, Series, Book, Page, Collection, ReadList
- Authentication (User, AuthenticationActivity)
- Reader (Page, ReadingDirection, ReaderBackground)
- Common (ServerInfo, Metrics, ThemeColor, etc.)

### **Services**
- `APIClient`: Core API communication
- `AuthService`: Authentication management
- `LibraryService`: Library operations
- `SeriesService`: Series operations
- `BookService`: Book operations
- `CollectionService`: Collection operations
- `ReadListService`: Read list operations
- `ImageCache`: Image caching with SDWebImage
- `ErrorManager`: Centralized error handling

### **ViewModels**
- `AuthViewModel`: Authentication state
- `LibraryViewModel`: Library management
- `SeriesViewModel`: Series browsing and filtering
- `BookViewModel`: Book browsing and management
- `CollectionViewModel`: Collection browsing
- `ReadListViewModel`: Read list browsing
- `ReaderViewModel`: Reading experience

### **Views**
- **Auth**: Login
- **Dashboard**: Home screen with recommendations
- **Browse**: Unified browsing (Series/Books/Collections/ReadLists)
- **History**: Reading history
- **Settings**: Comprehensive settings
- **Reader**: Multiple reading modes (LTR/RTL/Vertical/Webtoon)
- **Details**: Series/Book/Collection/ReadList detail views

---

## 🚀 Getting Started

### Prerequisites

- **iOS 17.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- A running [Komga server](https://github.com/gotson/komga)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/KMReader.git
   cd KMReader
   ```

2. **Open in Xcode**
   ```bash
   open KMReader.xcodeproj
   ```

3. **Build and Run**
   - Select your target device or simulator (iPhone 17 recommended)
   - Press `Cmd + R` to build and run

4. **First Launch**
   - Enter your Komga server URL (e.g., `http://192.168.1.100:25600` or `https://komga.example.com`)
   - Enter your username
   - Enter your password
   - Tap "Login"

### Configuration

The app automatically saves your server configuration and authentication token. You can:
- Change server settings in Settings → Account → Logout (then login again)
- View server information in Settings → Server Info
- Manage libraries in Settings → Libraries

---

## 🔌 API Compatibility

Compatible with **Komga API v1 and v2**:

- ✅ User Authentication (API v2)
- ✅ Libraries, Series, Books (API v1)
- ✅ Reading Progress & Book Pages (API v1)
- ✅ Collections & Read Lists (API v1)
- ✅ Server Info & Metrics (API v1)

---

## 📱 Screenshots

*Screenshots coming soon...*

---

## 🛣️ Roadmap

### Planned Features

#### Reader Enhancements
- [ ] Two-page spread function when screen is in landscape mode
- [ ] Skip cover option for two-page spread
- [ ] Reading direction auto-detection improvements
- [ ] Custom reading speed tracking

#### UI/UX Improvements
- [ ] Dark mode optimizations
- [ ] iPad layout improvements
- [ ] Widget support
- [ ] Shortcuts integration

#### Performance
- [ ] Background sync
- [ ] Offline reading support
- [ ] Enhanced caching strategies

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

---

## 🙏 Acknowledgments

- [Komga](https://github.com/gotson/komga) - The amazing media server this app connects to
- [SDWebImage](https://github.com/SDWebImage/SDWebImage) - Image loading and caching
- SwiftUI community for inspiration and best practices

---

<div align="center">

**Made with ❤️ for the Komga community**

⭐ Star this repo if you find it useful!

</div>

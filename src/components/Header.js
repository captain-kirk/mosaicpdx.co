import Link from 'next/link';

export default function Header() {
  return (
    <header className="header-custom">
      <div className="header-container">
        <div className="logo-section">
          <Link href="/">
            <img src="/images/logo.png" alt="Logo" className="header-logo" style={{ cursor: 'pointer' }} />
          </Link>
        </div>
        <nav className="nav-section">
          <Link href="/about" className="nav-link">
            About
          </Link>
          <Link href="/events" className="nav-link">
            Events
          </Link>
          {/* <Link href="/music" className="nav-link">
            Music
          </Link>
          <Link href="/outdoors" className="nav-link">
            Outdoors
          </Link>
          <Link href="/gallery" className="nav-link">
            Gallery
          </Link> */}
        </nav>
      </div>
    </header>
  );
}

import Header from './Header';
// import Footer from './Footer';

export default function Layout({ children }) {
  return (
    <div className="d-flex flex-column min-vh-100">
      <Header />
      <main className="container my-4 flex-grow-1" style={{ marginTop: '80px' }}>{children}</main>
      {/* <Footer /> */}
    </div>
  );
}
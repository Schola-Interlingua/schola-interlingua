import Header from './components/Header.jsx';
import Hero from './components/Hero.jsx';
import Features from './components/Features.jsx';
import Progress from './components/Progress.jsx';
import Course from './components/Course.jsx';
import Footer from './components/Footer.jsx';

function App() {
  return (
    <div className="flex flex-col min-h-screen">
      <Header />
      <Hero />
      <Features />
      <Progress />
      <Course />
      <Footer />
    </div>
  );
}

export default App;

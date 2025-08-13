import { Menu } from 'lucide-react';

const Header = () => (
  <header className="sticky top-0 backdrop-blur bg-white/70 shadow-sm z-10">
    <div className="max-w-5xl mx-auto px-4 py-3 flex items-center justify-between">
      <span className="font-heading text-xl text-primary">Schola</span>
      <Menu className="md:hidden" />
      <nav className="hidden md:flex gap-6 text-sm">
        <a href="#" className="hover:text-primary">Inicio</a>
        <a href="#" className="hover:text-primary">Curso</a>
        <a href="#" className="hover:text-primary">Progreso</a>
      </nav>
    </div>
  </header>
);

export default Header;

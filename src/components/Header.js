import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  BookOpen, 
  BarChart3, 
  GraduationCap, 
  Menu, 
  X,
  Globe,
  Download,
  Github
} from 'lucide-react';

const Header = ({ currentSection, setCurrentSection }) => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const navItems = [
    { id: 'home', label: 'Inicio', icon: Globe, color: 'text-primary-600' },
    { id: 'course', label: 'Curso', icon: BookOpen, color: 'text-secondary-600' },
    { id: 'progress', label: 'Progreso', icon: BarChart3, color: 'text-accent-600' },
  ];

  const handleNavClick = (sectionId) => {
    setCurrentSection(sectionId);
    setIsMobileMenuOpen(false);
  };

  return (
    <motion.header
      initial={{ y: -100 }}
      animate={{ y: 0 }}
      transition={{ duration: 0.6, ease: "easeOut" }}
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        isScrolled 
          ? 'bg-white/90 backdrop-blur-md shadow-medium border-b border-white/20' 
          : 'bg-transparent'
      }`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-20">
          {/* Logo */}
          <motion.div
            whileHover={{ scale: 1.05 }}
            className="flex items-center space-x-3 cursor-pointer"
            onClick={() => handleNavClick('home')}
          >
            <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-xl flex items-center justify-center shadow-glow">
              <GraduationCap className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-bold font-display gradient-text">Schola Interlingua</h1>
              <p className="text-xs text-neutral-500 -mt-1">Plataforma de Aprendizaje</p>
            </div>
          </motion.div>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center space-x-1">
            {navItems.map((item) => {
              const Icon = item.icon;
              return (
                <motion.button
                  key={item.id}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => handleNavClick(item.id)}
                  className={`flex items-center space-x-2 px-4 py-2 rounded-xl font-medium transition-all duration-200 ${
                    currentSection === item.id
                      ? 'bg-primary-100 text-primary-700 shadow-soft'
                      : 'text-neutral-600 hover:text-primary-600 hover:bg-primary-50'
                  }`}
                >
                  <Icon className={`w-5 h-5 ${item.color}`} />
                  <span>{item.label}</span>
                </motion.button>
              );
            })}
          </nav>

          {/* Action Buttons */}
          <div className="hidden md:flex items-center space-x-3">
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="btn btn-outline"
            >
              <Download className="w-4 h-4 mr-2" />
              Descargar Anki
            </motion.button>
            <motion.a
              href="https://github.com/schola-interlingua"
              target="_blank"
              rel="noopener noreferrer"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="p-3 rounded-xl bg-neutral-100 text-neutral-600 hover:bg-neutral-200 transition-colors duration-200"
            >
              <Github className="w-5 h-5" />
            </motion.a>
          </div>

          {/* Mobile Menu Button */}
          <motion.button
            whileTap={{ scale: 0.95 }}
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            className="md:hidden p-2 rounded-xl bg-neutral-100 text-neutral-600 hover:bg-neutral-200 transition-colors duration-200"
          >
            {isMobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </motion.button>
        </div>

        {/* Mobile Navigation */}
        <AnimatePresence>
          {isMobileMenuOpen && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              transition={{ duration: 0.3 }}
              className="md:hidden overflow-hidden"
            >
              <div className="py-4 space-y-2 border-t border-neutral-200">
                {navItems.map((item) => {
                  const Icon = item.icon;
                  return (
                    <motion.button
                      key={item.id}
                      whileTap={{ scale: 0.95 }}
                      onClick={() => handleNavClick(item.id)}
                      className={`w-full flex items-center space-x-3 px-4 py-3 rounded-xl font-medium transition-all duration-200 ${
                        currentSection === item.id
                          ? 'bg-primary-100 text-primary-700'
                          : 'text-neutral-600 hover:text-primary-600 hover:bg-primary-50'
                      }`}
                    >
                      <Icon className={`w-5 h-5 ${item.color}`} />
                      <span>{item.label}</span>
                    </motion.button>
                  );
                })}
                <div className="pt-2 border-t border-neutral-200">
                  <motion.button
                    whileTap={{ scale: 0.95 }}
                    className="w-full btn btn-outline"
                  >
                    <Download className="w-4 h-4 mr-2" />
                    Descargar Anki
                  </motion.button>
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </motion.header>
  );
};

export default Header;

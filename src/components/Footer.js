import React from 'react';
import { motion } from 'framer-motion';
import { 
  Github, 
  Twitter, 
  Mail, 
  Heart,
  Globe,
  BookOpen,
  Users,
  Download
} from 'lucide-react';

const Footer = () => {
  const currentYear = new Date().getFullYear();

  const footerSections = [
    {
      title: "Plataforma",
      links: [
        { name: "Inicio", href: "#" },
        { name: "Curso", href: "#" },
        { name: "Progreso", href: "#" },
        { name: "Recursos", href: "#" }
      ]
    },
    {
      title: "Recursos",
      links: [
        { name: "Gramática", href: "#" },
        { name: "Vocabulario", href: "#" },
        { name: "Ejercicios", href: "#" },
        { name: "Descargas", href: "#" }
      ]
    },
    {
      title: "Comunidad",
      links: [
        { name: "Foro", href: "#" },
        { name: "Discord", href: "#" },
        { name: "Contribuir", href: "#" },
        { name: "Contacto", href: "#" }
      ]
    },
    {
      title: "Legal",
      links: [
        { name: "Términos", href: "#" },
        { name: "Privacidad", href: "#" },
        { name: "Licencia", href: "#" },
        { name: "Cookies", href: "#" }
      ]
    }
  ];

  const socialLinks = [
    { name: "GitHub", icon: Github, href: "https://github.com/schola-interlingua", color: "hover:bg-neutral-800" },
    { name: "Twitter", icon: Twitter, href: "https://twitter.com/schola_interlingua", color: "hover:bg-blue-500" },
    { name: "Email", icon: Mail, href: "mailto:contact@schola-interlingua.org", color: "hover:bg-red-500" }
  ];

  return (
    <footer className="bg-gradient-to-br from-neutral-900 to-neutral-800 text-white relative overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute inset-0" style={{
          backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.1'%3E%3Ccircle cx='30' cy='30' r='2'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
        }} />
      </div>

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        {/* Main Footer Content */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-8 mb-12">
          {/* Brand Section */}
          <div className="lg:col-span-2">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
              viewport={{ once: true }}
              className="mb-6"
            >
              <div className="flex items-center space-x-3 mb-4">
                <div className="w-12 h-12 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-xl flex items-center justify-center">
                  <Globe className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h3 className="text-xl font-bold font-display">Schola Interlingua</h3>
                  <p className="text-sm text-neutral-300">Plataforma de Aprendizaje</p>
                </div>
              </div>
              <p className="text-neutral-300 leading-relaxed mb-6">
                La plataforma digital más moderna para aprender Interlingua IALA. 
                Software libre y open source para todos.
              </p>
              
              {/* Social Links */}
              <div className="flex space-x-3">
                {socialLinks.map((social) => {
                  const Icon = social.icon;
                  return (
                    <motion.a
                      key={social.name}
                      href={social.href}
                      target="_blank"
                      rel="noopener noreferrer"
                      whileHover={{ scale: 1.1, y: -2 }}
                      whileTap={{ scale: 0.95 }}
                      className={`w-10 h-10 bg-neutral-700 rounded-lg flex items-center justify-center text-neutral-300 transition-all duration-200 ${social.color}`}
                    >
                      <Icon className="w-5 h-5" />
                    </motion.a>
                  );
                })}
              </div>
            </motion.div>
          </div>

          {/* Footer Links */}
          {footerSections.map((section, sectionIndex) => (
            <motion.div
              key={section.title}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: sectionIndex * 0.1 }}
              viewport={{ once: true }}
            >
              <h4 className="text-lg font-semibold mb-4 text-white">{section.title}</h4>
              <ul className="space-y-2">
                {section.links.map((link) => (
                  <li key={link.name}>
                    <motion.a
                      href={link.href}
                      whileHover={{ x: 5 }}
                      className="text-neutral-300 hover:text-white transition-colors duration-200 text-sm"
                    >
                      {link.name}
                    </motion.a>
                  </li>
                ))}
              </ul>
            </motion.div>
          ))}
        </div>

        {/* Newsletter Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.4 }}
          viewport={{ once: true }}
          className="border-t border-neutral-700 pt-8 mb-8"
        >
          <div className="text-center">
            <h3 className="text-xl font-semibold mb-2">Mantente Actualizado</h3>
              <p className="text-neutral-300 mb-6">
                Recibe las últimas noticias sobre nuevas lecciones y características
              </p>
              <div className="flex flex-col sm:flex-row gap-3 max-w-md mx-auto">
                <input
                  type="email"
                  placeholder="Tu email"
                  className="flex-1 px-4 py-3 rounded-xl bg-neutral-700 border border-neutral-600 text-white placeholder-neutral-400 focus:outline-none focus:border-primary-500 focus:ring-2 focus:ring-primary-500/20 transition-all duration-200"
                />
                <motion.button
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  className="btn btn-primary px-6"
                >
                  Suscribirse
                </motion.button>
              </div>
            </div>
        </motion.div>

        {/* Bottom Bar */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.6 }}
          viewport={{ once: true }}
          className="border-t border-neutral-700 pt-8"
        >
          <div className="flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
            <div className="flex items-center space-x-2 text-neutral-400 text-sm">
              <span>© {currentYear} Schola Interlingua. Hecho con</span>
              <Heart className="w-4 h-4 text-red-500 fill-current" />
              <span>y software libre.</span>
            </div>
            
            <div className="flex items-center space-x-6 text-sm text-neutral-400">
              <div className="flex items-center space-x-2">
                <BookOpen className="w-4 h-4" />
                <span>v2.0.0</span>
              </div>
              <div className="flex items-center space-x-2">
                <Users className="w-4 h-4" />
                <span>1000+ estudiantes</span>
              </div>
              <div className="flex items-center space-x-2">
                <Download className="w-4 h-4" />
                <span>Open Source</span>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </footer>
  );
};

export default Footer;

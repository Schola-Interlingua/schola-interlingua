import React from 'react';
import { motion } from 'framer-motion';
import { 
  BookOpen, 
  Headphones, 
  FileText, 
  Target,
  Users,
  Award,
  Zap,
  Globe
} from 'lucide-react';

const FeaturesSection = () => {
  const features = [
    {
      icon: BookOpen,
      title: "Lecciones Estructuradas",
      description: "Contenido organizado progresivamente desde básico hasta avanzado",
      color: "from-primary-500 to-primary-600",
      bgColor: "from-primary-50 to-primary-100"
    },
    {
      icon: Headphones,
      title: "Audio Interactivo",
      description: "Pronunciación nativa y ejercicios de escucha para mejorar la comprensión",
      color: "from-secondary-500 to-secondary-600",
      bgColor: "from-secondary-50 to-secondary-100"
    },
    {
      icon: FileText,
      title: "Vocabulario Completo",
      description: "Más de 1000 palabras organizadas por temas y niveles de dificultad",
      color: "from-accent-500 to-accent-600",
      bgColor: "from-accent-50 to-accent-100"
    },
    {
      icon: Target,
      title: "Ejercicios Prácticos",
      description: "Cuestionarios, ejercicios de gramática y actividades interactivas",
      color: "from-success-500 to-success-600",
      bgColor: "from-success-50 to-success-100"
    },
    {
      icon: Users,
      title: "Comunidad Activa",
      description: "Conecta con otros estudiantes y comparte tu progreso",
      color: "from-warning-500 to-warning-600",
      bgColor: "from-warning-50 to-warning-100"
    },
    {
      icon: Award,
      title: "Sistema de Logros",
      description: "Gana badges y sigue tu progreso con métricas detalladas",
      color: "from-error-500 to-error-600",
      bgColor: "from-error-50 to-error-100"
    },
    {
      icon: Zap,
      title: "Aprendizaje Rápido",
      description: "Métodos optimizados para retener información a largo plazo",
      color: "from-primary-500 to-secondary-500",
      bgColor: "from-primary-50 to-secondary-50"
    },
    {
      icon: Globe,
      title: "Acceso Universal",
      description: "Disponible en cualquier dispositivo, sin conexión incluida",
      color: "from-secondary-500 to-accent-500",
      bgColor: "from-secondary-50 to-accent-50"
    }
  ];

  return (
    <section className="py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-br from-neutral-50 to-white">
      <div className="max-w-7xl mx-auto">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: true }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl md:text-5xl font-bold font-display text-neutral-800 mb-6">
            ¿Por qué elegir{' '}
            <span className="gradient-text">Schola Interlingua</span>?
          </h2>
          <p className="text-xl text-neutral-600 max-w-3xl mx-auto">
            Nuestra plataforma combina la mejor tecnología educativa con métodos probados 
            para crear una experiencia de aprendizaje única y efectiva.
          </p>
        </motion.div>

        {/* Features Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {features.map((feature, index) => {
            const Icon = feature.icon;
            return (
              <motion.div
                key={feature.title}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                viewport={{ once: true }}
                whileHover={{ y: -8, scale: 1.02 }}
                className="group cursor-pointer"
              >
                <div className={`card p-6 h-full bg-gradient-to-br ${feature.bgColor} border-0 hover:shadow-large transition-all duration-300`}>
                  <div className={`w-12 h-12 bg-gradient-to-br ${feature.color} rounded-xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform duration-300 shadow-soft`}>
                    <Icon className="w-6 h-6 text-white" />
                  </div>
                  <h3 className="text-lg font-bold font-display text-neutral-800 mb-3 group-hover:text-primary-700 transition-colors duration-300">
                    {feature.title}
                  </h3>
                  <p className="text-neutral-600 text-sm leading-relaxed">
                    {feature.description}
                  </p>
                </div>
              </motion.div>
            );
          })}
        </div>

        {/* Call to Action */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.5 }}
          viewport={{ once: true }}
          className="text-center mt-16"
        >
          <div className="card p-8 max-w-2xl mx-auto bg-gradient-to-r from-primary-50 to-secondary-50 border-primary-200">
            <h3 className="text-2xl font-bold font-display text-neutral-800 mb-4">
              ¿Listo para comenzar tu viaje?
            </h3>
            <p className="text-neutral-600 mb-6">
              Únete a miles de estudiantes que ya están aprendiendo Interlingua con nosotros.
            </p>
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="btn btn-primary text-lg px-8 py-4 shadow-glow hover:shadow-glow-success"
            >
              Comenzar Ahora
            </motion.button>
          </div>
        </motion.div>
      </div>
    </section>
  );
};

export default FeaturesSection;

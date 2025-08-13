import { motion } from 'framer-motion';

const Hero = () => (
  <section className="text-center py-24 bg-gradient-to-br from-primary to-secondary text-white">
    <motion.h1
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="text-4xl font-heading mb-6"
    >
      Aprende Interlingua Modernamente
    </motion.h1>
    <motion.p
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.2 }}
      className="max-w-xl mx-auto mb-8"
    >
      Plataforma interactiva para dominar el idioma de forma rápida y divertida.
    </motion.p>
    <motion.button
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
      className="bg-accent px-6 py-3 rounded-full font-semibold shadow-lg"
    >
      Comenzar
    </motion.button>
  </section>
);

export default Hero;

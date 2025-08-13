import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { 
  BookOpen, 
  Play, 
  Lock, 
  CheckCircle,
  Clock,
  Star,
  Download,
  Headphones,
  FileText,
  Target,
  Users,
  Award
} from 'lucide-react';

const CourseSection = () => {
  const [selectedLevel, setSelectedLevel] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');

  const levels = [
    { id: 'all', name: 'Todos', color: 'from-neutral-500 to-neutral-600' },
    { id: 'beginner', name: 'Principiante', color: 'from-success-500 to-success-600' },
    { id: 'intermediate', name: 'Intermedio', color: 'from-primary-500 to-primary-600' },
    { id: 'advanced', name: 'Avanzado', color: 'from-secondary-500 to-secondary-600' }
  ];

  const lessons = [
    {
      id: 1,
      title: "Introducción a Interlingua",
      description: "Conceptos básicos y pronunciación",
      level: "beginner",
      duration: "15 min",
      status: "completed",
      score: 95,
      hasAudio: true,
      hasExercises: true,
      hasVocabulary: true,
      difficulty: 1
    },
    {
      id: 2,
      title: "Saludos y Presentaciones",
      description: "Aprende a saludar y presentarte",
      level: "beginner",
      duration: "20 min",
      status: "completed",
      score: 88,
      hasAudio: true,
      hasExercises: true,
      hasVocabulary: true,
      difficulty: 1
    },
    {
      id: 3,
      title: "Artículos y Sustantivos",
      description: "Fundamentos de la gramática básica",
      level: "beginner",
      duration: "25 min",
      status: "completed",
      score: 92,
      hasAudio: true,
      hasExercises: true,
      hasVocabulary: true,
      difficulty: 2
    },
    {
      id: 4,
      title: "Pronombres Personales",
      description: "Uso correcto de pronombres",
      level: "beginner",
      duration: "20 min",
      status: "in-progress",
      score: 0,
      hasAudio: true,
      hasExercises: true,
      hasVocabulary: true,
      difficulty: 2
    },
    {
      id: 5,
      title: "Verbos Regulares",
      description: "Conjugación de verbos básicos",
      level: "intermediate",
      duration: "30 min",
      status: "locked",
      score: 0,
      hasAudio: true,
      hasExercises: true,
      hasVocabulary: true,
      difficulty: 3
    },
    {
      id: 6,
      title: "Adjetivos y Comparativos",
      description: "Descripción y comparación",
      level: "intermediate",
      duration: "25 min",
      status: "locked",
      score: 0,
      hasAudio: true,
      hasExercises: true,
      hasVocabulary: true,
      difficulty: 3
    },
    {
      id: 7,
      title: "Tiempos Verbales",
      description: "Presente, pasado y futuro",
      level: "intermediate",
      duration: "35 min",
      status: "locked",
      score: 0,
      hasAudio: true,
      hasExercises: true,
      hasVocabulary: true,
      difficulty: 4
    },
    {
      id: 8,
      title: "Expresiones Idiomáticas",
      description: "Frases y modismos comunes",
      level: "advanced",
      duration: "40 min",
      status: "locked",
      score: 0,
      hasAudio: true,
      hasExercises: true,
      hasVocabulary: true,
      difficulty: 5
    }
  ];

  const filteredLessons = lessons.filter(lesson => {
    const matchesLevel = selectedLevel === 'all' || lesson.level === selectedLevel;
    const matchesSearch = lesson.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         lesson.description.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesLevel && matchesSearch;
  });

  const getDifficultyColor = (difficulty) => {
    const colors = [
      'from-success-500 to-success-600',
      'from-success-500 to-warning-500',
      'from-warning-500 to-warning-600',
      'from-warning-500 to-error-500',
      'from-error-500 to-error-600'
    ];
    return colors[difficulty - 1] || colors[0];
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'completed':
        return <CheckCircle className="w-5 h-5 text-success-500" />;
      case 'in-progress':
        return <Play className="w-5 h-5 text-primary-500" />;
      case 'locked':
        return <Lock className="w-5 h-5 text-neutral-400" />;
      default:
        return <BookOpen className="w-5 h-5 text-neutral-400" />;
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'completed':
        return 'bg-success-100 text-success-700 border-success-200';
      case 'in-progress':
        return 'bg-primary-100 text-primary-700 border-primary-200';
      case 'locked':
        return 'bg-neutral-100 text-neutral-500 border-neutral-200';
      default:
        return 'bg-neutral-100 text-neutral-500 border-neutral-200';
    }
  };

  return (
    <section className="py-20 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="text-center mb-16"
        >
          <h1 className="text-4xl md:text-5xl font-bold font-display text-neutral-800 mb-6">
            Curso de <span className="gradient-text">Interlingua</span>
          </h1>
          <p className="text-xl text-neutral-600 max-w-3xl mx-auto">
            Explora nuestras lecciones estructuradas y comienza tu viaje hacia el dominio del idioma internacional
          </p>
        </motion.div>

        {/* Filters and Search */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="mb-12"
        >
          <div className="card p-6">
            <div className="flex flex-col lg:flex-row gap-6 items-center">
              {/* Level Filter */}
              <div className="flex flex-wrap gap-2">
                {levels.map((level) => (
                  <motion.button
                    key={level.id}
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={() => setSelectedLevel(level.id)}
                    className={`px-4 py-2 rounded-xl font-medium transition-all duration-200 ${
                      selectedLevel === level.id
                        ? `bg-gradient-to-r ${level.color} text-white shadow-soft`
                        : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
                    }`}
                  >
                    {level.name}
                  </motion.button>
                ))}
              </div>

              {/* Search */}
              <div className="flex-1 max-w-md">
                <div className="relative">
                  <input
                    type="text"
                    placeholder="Buscar lecciones..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="input pl-10"
                  />
                  <BookOpen className="w-5 h-5 text-neutral-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
                </div>
              </div>

              {/* Download All */}
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="btn btn-outline"
              >
                <Download className="w-4 h-4 mr-2" />
                Descargar Todo
              </motion.button>
            </div>
          </div>
        </motion.div>

        {/* Lessons Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredLessons.map((lesson, index) => (
            <motion.div
              key={lesson.id}
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.3 + index * 0.1 }}
              whileHover={{ y: -5, scale: 1.02 }}
              className="card p-6 h-full cursor-pointer group"
            >
              {/* Lesson Header */}
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center space-x-2">
                  {getStatusIcon(lesson.status)}
                  <span className={`px-2 py-1 rounded-lg text-xs font-medium border ${getStatusColor(lesson.status)}`}>
                    {lesson.status === 'completed' ? 'Completado' : 
                     lesson.status === 'in-progress' ? 'En Progreso' : 'Bloqueado'}
                  </span>
                </div>
                <div className={`px-2 py-1 rounded-lg text-xs font-medium bg-gradient-to-r ${getDifficultyColor(lesson.difficulty)} text-white`}>
                  Nivel {lesson.difficulty}
                </div>
              </div>

              {/* Lesson Content */}
              <h3 className="text-lg font-bold font-display text-neutral-800 mb-2 group-hover:text-primary-600 transition-colors duration-200">
                {lesson.title}
              </h3>
              <p className="text-neutral-600 text-sm mb-4 leading-relaxed">
                {lesson.description}
              </p>

              {/* Lesson Stats */}
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center space-x-2 text-sm text-neutral-500">
                  <Clock className="w-4 h-4" />
                  <span>{lesson.duration}</span>
                </div>
                {lesson.status === 'completed' && (
                  <div className="flex items-center space-x-1">
                    <Star className="w-4 h-4 text-warning-500 fill-current" />
                    <span className="text-sm font-medium text-neutral-600">{lesson.score}%</span>
                  </div>
                )}
              </div>

              {/* Features */}
              <div className="flex items-center space-x-3 mb-4">
                {lesson.hasAudio && (
                  <div className="flex items-center space-x-1 text-xs text-neutral-500">
                    <Headphones className="w-3 h-3" />
                    <span>Audio</span>
                  </div>
                )}
                {lesson.hasExercises && (
                  <div className="flex items-center space-x-1 text-xs text-neutral-500">
                    <Target className="w-3 h-3" />
                    <span>Ejercicios</span>
                  </div>
                )}
                {lesson.hasVocabulary && (
                  <div className="flex items-center space-x-1 text-xs text-neutral-500">
                    <FileText className="w-3 h-3" />
                    <span>Vocabulario</span>
                  </div>
                )}
              </div>

              {/* Action Button */}
              <motion.button
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                disabled={lesson.status === 'locked'}
                className={`w-full btn ${
                  lesson.status === 'completed' 
                    ? 'btn-success' 
                    : lesson.status === 'in-progress'
                    ? 'btn-primary'
                    : 'btn-secondary'
                }`}
              >
                {lesson.status === 'completed' ? 'Repasar' : 
                 lesson.status === 'in-progress' ? 'Continuar' : 'Bloqueado'}
              </motion.button>
            </motion.div>
          ))}
        </div>

        {/* Course Stats */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.8 }}
          className="mt-16"
        >
          <div className="card p-8 bg-gradient-to-r from-primary-50 to-secondary-50 border-primary-200">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6 text-center">
              <div>
                <div className="text-3xl font-bold text-primary-600 mb-2">
                  {lessons.length}
                </div>
                <div className="text-neutral-600">Lecciones Totales</div>
              </div>
              <div>
                <div className="text-3xl font-bold text-success-600 mb-2">
                  {lessons.filter(l => l.status === 'completed').length}
                </div>
                <div className="text-neutral-600">Completadas</div>
              </div>
              <div>
                <div className="text-3xl font-bold text-warning-600 mb-2">
                  {lessons.filter(l => l.status === 'in-progress').length}
                </div>
                <div className="text-neutral-600">En Progreso</div>
              </div>
              <div>
                <div className="text-3xl font-bold text-neutral-600 mb-2">
                  {lessons.filter(l => l.status === 'locked').length}
                </div>
                <div className="text-neutral-600">Bloqueadas</div>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
};

export default CourseSection;

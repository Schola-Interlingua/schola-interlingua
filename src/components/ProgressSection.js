import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { 
  BarChart3, 
  TrendingUp, 
  Calendar, 
  Target,
  Download,
  Upload,
  Fire,
  Trophy,
  BookOpen,
  CheckCircle,
  Clock,
  Star
} from 'lucide-react';

const ProgressSection = () => {
  const [progress, setProgress] = useState({
    completedLessons: 12,
    totalLessons: 50,
    currentStreak: 7,
    bestStreak: 15,
    totalStudyTime: 28,
    accuracy: 87,
    level: 'Intermedio',
    nextLesson: 'Lección 13: Verbos Irregulares'
  });

  const [isExporting, setIsExporting] = useState(false);
  const [isImporting, setIsImporting] = useState(false);

  const achievements = [
    { name: 'Primer Paso', icon: CheckCircle, color: 'text-success-500', bgColor: 'bg-success-100' },
    { name: 'Estudiante Dedicado', icon: BookOpen, color: 'text-primary-500', bgColor: 'bg-primary-100' },
    { name: 'Racha de 7 Días', icon: Fire, color: 'text-warning-500', bgColor: 'bg-warning-100' },
    { name: 'Precisión 85%+', icon: Target, color: 'text-accent-500', bgColor: 'bg-accent-100' }
  ];

  const recentActivity = [
    { lesson: 'Lección 12', status: 'completed', time: '2h ago', score: 92 },
    { lesson: 'Lección 11', status: 'completed', time: '1d ago', score: 88 },
    { lesson: 'Lección 10', status: 'completed', time: '2d ago', score: 95 },
    { lesson: 'Lección 9', status: 'completed', time: '3d ago', score: 85 }
  ];

  const handleExport = async () => {
    setIsExporting(true);
    // Simulate export process
    await new Promise(resolve => setTimeout(resolve, 2000));
    setIsExporting(false);
    // Here you would implement actual export logic
  };

  const handleImport = async () => {
    setIsImporting(true);
    // Simulate import process
    await new Promise(resolve => setTimeout(resolve, 2000));
    setIsImporting(false);
    // Here you would implement actual import logic
  };

  const completionPercentage = (progress.completedLessons / progress.totalLessons) * 100;

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
            Tu <span className="gradient-text">Progreso</span>
          </h1>
          <p className="text-xl text-neutral-600 max-w-3xl mx-auto">
            Sigue tu evolución en el aprendizaje de Interlingua y celebra tus logros
          </p>
        </motion.div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Progress Card */}
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="lg:col-span-2"
          >
            <div className="card p-8">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-2xl font-bold font-display text-neutral-800">
                  Progreso General
                </h2>
                <div className="flex items-center space-x-2">
                  <Trophy className="w-6 h-6 text-warning-500" />
                  <span className="text-sm font-medium text-neutral-600">Nivel {progress.level}</span>
                </div>
              </div>

              {/* Progress Bar */}
              <div className="mb-6">
                <div className="flex justify-between items-center mb-2">
                  <span className="text-sm font-medium text-neutral-600">
                    {progress.completedLessons} de {progress.totalLessons} lecciones
                  </span>
                  <span className="text-sm font-bold text-primary-600">
                    {Math.round(completionPercentage)}%
                  </span>
                </div>
                <div className="w-full bg-neutral-200 rounded-full h-3 overflow-hidden">
                  <motion.div
                    initial={{ width: 0 }}
                    animate={{ width: `${completionPercentage}%` }}
                    transition={{ duration: 1, delay: 0.5 }}
                    className="h-full bg-gradient-to-r from-primary-500 to-secondary-500 rounded-full"
                  />
                </div>
              </div>

              {/* Stats Grid */}
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="text-center p-4 bg-gradient-to-br from-primary-50 to-primary-100 rounded-xl">
                  <div className="text-2xl font-bold text-primary-600 mb-1">
                    {progress.completedLessons}
                  </div>
                  <div className="text-sm text-neutral-600">Lecciones</div>
                </div>
                <div className="text-center p-4 bg-gradient-to-br from-secondary-50 to-secondary-100 rounded-xl">
                  <div className="text-2xl font-bold text-secondary-600 mb-1">
                    {progress.currentStreak}
                  </div>
                  <div className="text-sm text-neutral-600">Días Racha</div>
                </div>
                <div className="text-center p-4 bg-gradient-to-br from-accent-50 to-accent-100 rounded-xl">
                  <div className="text-2xl font-bold text-accent-600 mb-1">
                    {progress.totalStudyTime}h
                  </div>
                  <div className="text-sm text-neutral-600">Tiempo Total</div>
                </div>
                <div className="text-center p-4 bg-gradient-to-br from-success-50 to-success-100 rounded-xl">
                  <div className="text-2xl font-bold text-success-600 mb-1">
                    {progress.accuracy}%
                  </div>
                  <div className="text-sm text-neutral-600">Precisión</div>
                </div>
              </div>

              {/* Next Lesson */}
              <div className="mt-6 p-4 bg-gradient-to-r from-neutral-50 to-primary-50 rounded-xl border border-primary-200">
                <div className="flex items-center space-x-3">
                  <Clock className="w-5 h-5 text-primary-600" />
                  <div>
                    <div className="text-sm font-medium text-neutral-600">Próxima lección</div>
                    <div className="font-semibold text-neutral-800">{progress.nextLesson}</div>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Sidebar */}
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="space-y-6"
          >
            {/* Streak Card */}
            <div className="card p-6">
              <div className="flex items-center space-x-3 mb-4">
                <div className="w-10 h-10 bg-gradient-to-br from-warning-500 to-accent-500 rounded-xl flex items-center justify-center">
                  <Fire className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h3 className="font-bold text-neutral-800">Racha Actual</h3>
                  <p className="text-sm text-neutral-600">Días consecutivos</p>
                </div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-warning-600 mb-1">
                  {progress.currentStreak}
                </div>
                <div className="text-sm text-neutral-500">
                  Mejor: {progress.bestStreak} días
                </div>
              </div>
            </div>

            {/* Achievements */}
            <div className="card p-6">
              <h3 className="font-bold text-neutral-800 mb-4 flex items-center">
                <Star className="w-5 h-5 text-warning-500 mr-2" />
                Logros
              </h3>
              <div className="space-y-3">
                {achievements.map((achievement, index) => {
                  const Icon = achievement.icon;
                  return (
                    <motion.div
                      key={achievement.name}
                      initial={{ opacity: 0, x: 20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ duration: 0.5, delay: 0.6 + index * 0.1 }}
                      className="flex items-center space-x-3 p-3 rounded-lg bg-neutral-50"
                    >
                      <div className={`w-8 h-8 ${achievement.bgColor} rounded-lg flex items-center justify-center`}>
                        <Icon className={`w-4 h-4 ${achievement.color}`} />
                      </div>
                      <span className="text-sm font-medium text-neutral-700">
                        {achievement.name}
                      </span>
                    </motion.div>
                  );
                })}
              </div>
            </div>

            {/* Export/Import */}
            <div className="card p-6">
              <h3 className="font-bold text-neutral-800 mb-4">Respaldo</h3>
              <div className="space-y-3">
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={handleExport}
                  disabled={isExporting}
                  className="w-full btn btn-outline text-sm"
                >
                  <Download className="w-4 h-4 mr-2" />
                  {isExporting ? 'Exportando...' : 'Exportar Progreso'}
                </motion.button>
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={handleImport}
                  disabled={isImporting}
                  className="w-full btn btn-secondary text-sm"
                >
                  <Upload className="w-4 h-4 mr-2" />
                  {isImporting ? 'Importando...' : 'Importar Progreso'}
                </motion.button>
              </div>
            </div>
          </motion.div>
        </div>

        {/* Recent Activity */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.6 }}
          className="mt-16"
        >
          <div className="card p-8">
            <h2 className="text-2xl font-bold font-display text-neutral-800 mb-6">
              Actividad Reciente
            </h2>
            <div className="space-y-4">
              {recentActivity.map((activity, index) => (
                <motion.div
                  key={activity.lesson}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ duration: 0.5, delay: 0.8 + index * 0.1 }}
                  className="flex items-center justify-between p-4 bg-neutral-50 rounded-xl"
                >
                  <div className="flex items-center space-x-3">
                    <div className={`w-3 h-3 rounded-full ${
                      activity.status === 'completed' ? 'bg-success-500' : 'bg-warning-500'
                    }`} />
                    <div>
                      <div className="font-medium text-neutral-800">{activity.lesson}</div>
                      <div className="text-sm text-neutral-500">{activity.time}</div>
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    <span className="text-sm font-medium text-neutral-600">Puntuación:</span>
                    <span className="text-lg font-bold text-success-600">{activity.score}%</span>
                  </div>
                </motion.div>
              ))}
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
};

export default ProgressSection;

import { Book, Award, Zap } from 'lucide-react';

const features = [
  { icon: Book, title: 'Lecciones Modernas' },
  { icon: Award, title: 'Seguimiento de Progreso' },
  { icon: Zap, title: 'Interactividad' },
];

const Features = () => (
  <section className="py-16 max-w-5xl mx-auto px-4 grid gap-8 md:grid-cols-3">
    {features.map(({ icon: Icon, title }) => (
      <div key={title} className="text-center space-y-3">
        <Icon className="mx-auto text-primary" size={32} />
        <h3 className="font-heading">{title}</h3>
        <p className="text-sm text-gray-600">Descripción breve de {title.toLowerCase()}.</p>
      </div>
    ))}
  </section>
);

export default Features;

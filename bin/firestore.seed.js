const admin = require('firebase-admin');

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const reports = db.collection('reports');

const values = {
  sargassesLevel: 0,
  wavesLevel: 0,
  crowdLevel: 0,
  noiseLevel: 0,
  "rating": 0,
  "timestamp": (new Date()).toLocaleString(),
};

const beaches = [
  // {
  //   "beachId": "anse-bertrand-plage-de-la-chapelle",
  //   "beachName": "Anse-Bertrand - Plage de la Chapelle",
  //   "imagePath": "anse-bertrand-plage-de-la-chapelle-min.jpg",
  //   "comment": "Une très jolie plage, avec parfois quelques vagues. Le point fort est l'aire de jeu sur place et la facilité à trouver de l'ombre!",
  //   ...values
  // },
  {
    "beachId": "bouillante-plage-de-malendure",
    "beachName": "Bouillante - Plage de Malendure",
    "imagePath": "bouillante-plage-de-malendure-min.jpg",
    "comment": "Une jolie plage de sable brun, où l'on voit facilement des tortues marines. Prenez masque et tuba et appréciez.",
    ...values
  },
  {
    "beachId": "deshaies-plage-de-grande-anse",
    "beachName": "Deshaies - Plage de la Grande Anse",
    "imagePath": "deshaies-plage-de-grande-anse-min.jpg",
    "comment": "L'une des plus belles plages de l'île. Les vagues peuvent être fortes, mais la vue est incroyable!",
    ...values
  },
  {
    "beachId": "deshaies-plage-de-la-perle",
    "beachName": "Deshaies - Plage de la Perle",
    "imagePath": "deshaies-plage-de-grande-anse-min.jpg",
    "comment": "Cette plage est sublime! Il peut certes y avoir pas mal de vagues, mais ne quittez pas la Guadeloupe sans y être passés.",
    ...values
  },
  {
    "beachId": "gosier-plage-de-la-datcha",
    "beachName": "Le Gosier - Plage de la Datcha",
    "imagePath": "gosier-plage-de-la-datcha-min.jpg",
    "comment": "Vue magnifique sur l'îlet, juste en face. Ambiance festive (comprenez: bruyante), mais le sable est doux et il n'y a pas de vagues.",
    ...values
  },
  {
    "beachId": "gosier-plage-ilet-du-gosier",
    "beachName": "Le Gosier - Îlet du Gosier",
    "imagePath": "gosier-plage-ilet-du-gosier-min.jpg",
    "comment": "Quel endroit fantastique! Pas de vague, eaux turquoises et sable fin et... Le côté Robinson Crusoé en plus!",
    ...values
  },
  {
    "beachId": "la-desirade-plage",
    "beachName": "La désirade - Plage à Fifi",
    "imagePath": "la-desirade-plage-min.jpg",
    "comment": "La Désirade, si vous la visitez en dehors de la saison des sargasses, c'est quelque chose!",
    ...values
  },
  {
    "beachId": "le-moule-plage",
    "beachName": "Le Moule - Plage de l'autre bord",
    "imagePath": "le-moule-plage-min.jpg",
    "comment": "Jolie vue, sable doux. Quelques vagues, qui secouent mais amusent beaucoup les enfants!",
    ...values
  },
  {
    "beachId": "les-saintes-plage",
    "beachName": "Les Saintes - Plage du pain de sucre",
    "imagePath": "les-saintes-plage-min.jpg",
    "comment": "Le paradis, tout simplement! À voir absolument.",
    ...values
  },
  {
    "beachId": "marie-galante-plage",
    "beachName": "Marie-Galante - Plage de la Feuillère",
    "imagePath": "marie-galante-plage-min.jpg",
    "comment": "Si vous vous demandez pourquoi tout le monde parle de Marie-Galante!",
    ...values
  },
  {
    "beachId": "port-louis-plage-du-souffleur",
    "beachName": "Port-Louis - Plage du Souffleur",
    "imagePath": "port-louis-plage-du-souffleur-min.jpg",
    "comment": "Très belle plage. Magnifique, même! L'eau est souvent calme et d'une clarté hallucinante!",
    ...values
  },
  {
    "beachId": "plage-caravelle",
    "beachName": "Plage de la Caravelle",
    "imagePath": "ste-anne-plage-de-la-caravelle",
    "comment": "La carte postale par excellence: mer calme, eau limpide, sable blanc et cocotiers. Evidemment, beaucoup de monde sur place!",
    ...values
  },
  {
    "beachId": "ste-anne-plage-du-bourg",
    "beachName": "Ste-Anne - Plage du Bourg",
    "imagePath": "ste-anne-plage-du-bourg-min.jpg",
    "comment": "Très appréciée pour son absence de vagues, la blancheur de son sable et les commerces tout proches. Beaucoup de monde en général.",
    ...values
  },
  {
    "beachId": "ste-rose-plage-de-cluny",
    "beachName": "Ste-Rose - Plage de Cluny",
    "imagePath": "ste-rose-plage-de-cluny-min.jpg",
    "comment": "Très agréable, pour son sable, pour la vue et pour son authenticité. Peut-être parfois bruyante, mais l'une de nos préférées malgré tout!",
    ...values
  },
  {
    "beachId": "st-françois-plage",
    "beachName": "St-François - Plage des raisins clairs",
    "imagePath": "st-françois-plage-min.jpg",
    "comment": "St-François, ça vaut le détour! Ne serait-ce pour tout ce que l'on peut faire sur place.",
    ...values
  }

];

async function insertBeaches() {
  try {
    for (const beach of beaches) {
      await reports.add(beach);
      console.log(`Inséré : ${beach.beachName}`);
    }
    console.log('Migration terminée !');
  } catch (error) {
    console.error('Erreur lors de l\'insertion :', error);
  }
}

insertBeaches().then(() => {
  console.log('Tous les inserts terminés.');
  process.exit(0);
});

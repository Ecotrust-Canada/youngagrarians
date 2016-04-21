categories = Category.create [
  { name: 'Apprenticeship' },
  { name: 'Business' },
  { name: 'Education' }
]

subcategories = Subcategory.create [
  { name: 'Education', category: Category.first },
  { name: 'Farm Business Planning', category: Category.all.second },
  { name: 'University', category: Category.all.third }
], without_protection: true

def seed_locations
  Rails.logger.info 'Seeding locations'

  locations = Location.create [
    {
      latitude: 45.394939, longitude: -128.203445,
      gmaps: true,
      street_address: '1 Athelets Way',
      city: 'Vancouver', province: 'BC', country: 'Canada',
      name: 'Tap & Barrel',
      content: 'Things',
      bioregion: 'Vancouver',
      phone: '6045556669',
      url: 'tapandbarrel.ca',
      description: 'Apparently awesome pub place',
      category: Category.first,
      is_approved: false
    },
    {
      latitude: 45.394939, longitude: -128.203445,
      gmaps: true,
      street_address: '1 Athelets Way',
      city: 'Vancouver', province: 'BC', country: 'Canada',
      name: 'Tap & Barrel',
      content: 'Things',
      bioregion: 'Vancouver',
      phone: '6045556669',
      url: 'tapandbarrel.ca',
      description: 'Apparently awesome pub place',
      category: Category.all.second,
      is_approved: false
    },
    {
      latitude: 45.394939, longitude: -128.203445,
      gmaps: true,
      street_address: '1 Athelets Way',
      city: 'Vancouver', province: 'BC', country: 'Canada',
      name: 'Tap & Barrel',
      content: 'Things',
      bioregion: 'Vancouver',
      phone: '6045556669',
      url: 'tapandbarrel.ca',
      description: 'Apparently awesome pub place',
      category: Category.all.third,
      is_approved: false
    },
    {
      latitude: 45.394939, longitude: -128.203445,
      gmaps: true,
      street_address: '1 Athelets Way',
      city: 'Vancouver', province: 'BC', country: 'Canada',
      name: 'Tap & Barrel',
      content: 'Things',
      bioregion: 'Vancouver',
      phone: '6045556669',
      url: 'tapandbarrel.ca',
      description: 'Apparently awesome pub place',
      category: Category.first, is_approved: false
    }], without_protection: true

  locations[0].subcategories << Subcategory.first
  locations[1].subcategories << Subcategory.all.second
  locations[2].subcategories << Subcategory.all.third
end

def seed_users
  Rails.logger.info 'Seeding users'

  # ---------------------------------------------------------------------

  User.create(
    username: 'vincent',
    first_name: 'Vincent',
    last_name: 'van Haaff',
    email: 'vincent@vanhaaff.com',
    password: 'test42'
  )

  # ---------------------------------------------------------------------

  User.create(
    username: 'sean',
    first_name: 'Sean',
    last_name: 'Hagen',
    email: 'sean.hagen@gmail.com',
    password: 'test42'
  )

  # ---------------------------------------------------------------------

  User.create(
    username: 'sara',
    first_name: 'Sara',
    last_name: 'Dent',
    email: 'dentsara@gmail.com',
    password: 'test42'
  )
end

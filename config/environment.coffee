module.exports =
  development:
    app:
      name: 'Tracking'
    root: require('path').normalize(__dirname + '/..')
    mongodb: process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost/tracking_dev'
    redis:
      port: 6379
      host: 'localhost'
    postgres: process.env.POSTGRESQL_URI || process.env.POSTGRESQL_URL || 'tcp://andrii:andrii@localhost/tracking_dev'
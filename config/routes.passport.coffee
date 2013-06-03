module.exports = (app, passport, auth) ->

  local = (req, res, next)->
    passport.authenticate('local',
        failureRedirect: '/login'
        failureFlash: yes
        successFlash: yes
      , (err, user, info)->
        return next(err) if err
        unless user
          req.flash 'error', info.message
          return res.redirect '/login'
        req.login user, (err)->
          return next(err) if err
          req.flash 'success', 'Logged in'
          return_to = req.session.return_to
          delete req.session.return_to
          res.redirect return_to or '/'
    )(req, res, next)

  remember = (req, res, next) ->
    if req.body.remember_me
      req.session.cookie.maxAge = 30 * 24 * 60 * 60 * 1000
      req.session.random = Math.random()
    else
      req.session.cookie.expires = false
    next()

  app.post '/login', remember, local
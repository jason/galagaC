class Game
  constructor: (@canvas) ->
    @ctx = @canvas.getContext('2d')
    @width = @canvas.width
    @height = @canvas.height
    @FPS = 60

    @hero = new Hero(@width / 2, @height - 40)
    @score = 0
    @aliens = []
    @setAlienGrid()

  update: =>
    @checkUserMovement()
    bullet.update() for bullet in @hero.bullets
    alien.update() for alien in @aliens
    @checkCollisions()
    @removeOffScreenObjects()
    @draw()

  draw: ->
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
    @hero.draw(@ctx)
    bullet.draw(@ctx) for bullet in @hero.bullets
    alien.draw(@ctx) for alien in @aliens
    @showScore()

  showScore: ->
    @ctx.beginPath()
    @ctx.font = "bold 36px sans-serif";
    @ctx.fillStyle = "white"
    @ctx.fillText("Score: #{@score}", 100, 100);
    @ctx.closePath()

  checkCollisions: ->
    # check for dead aliens
    deadAliens = []
    deadBullets = []
    for bullet in @hero.bullets
      for alien in @aliens
        if alien.isHit(bullet)
          alien.explode(@ctx)
          deadBullets.push(bullet)
          deadAliens.push(alien)
          @score += 50
    @hero.bullets = _.difference(@hero.bullets, deadBullets)
    setTimeout( =>
      @aliens = _.difference(@aliens, deadAliens)
    , 650)

    # check for alien/player collision
    for alien in @aliens
      if alien.isHit(@hero)
        alien.explode()
        @gameOver()

  gameOver: ->
    clearInterval(@timer)
    alert "Death to Vader! All hail Luke!"

  setAlienGrid: ->
    @alienRows = []
    @rowHeight = 100
    _.times(parseInt((@height - 200) / @rowHeight, 10), (i) =>
      @alienRows.push((i + 1) * @rowHeight)
    )
    @availableRow = 0

  createAlienWave: ->
    # 2-5 aliens at a time
    maxAliens = @width / 100
    alienCount = Math.floor(Math.random() * (maxAliens - 5)) + 2

    positions = []
    _.times(alienCount, (i) =>
      positions.push([(i + 1) * 100 + ((@width - alienCount * 100) / 2), @alienRows[@availableRow]])
    )

    if @availableRow >= @alienRows.length - 1
      @availableRow = 0
    else
    @aliens.push(new Alien(pos[0], pos[1])) for pos in positions

  removeOffScreenObjects: ->
    # remove bullets
    offScreenBullets = []
    for bullet in @hero.bullets
      if @offScreen(bullet)
        offScreenBullets.push(bullet)
    @hero.bullets = _.difference(@hero.bullets, offScreenBullets)

    # remove aliens
    offScreenAliens = []
    for alien in @aliens
      if @offScreen(alien)
        offScreenAliens.push(alien)
    @aliens = _.difference(@aliens, offScreenAliens)

  offScreen: (obj) ->
    obj.posX > @width || obj.posX < 0 || obj.posY > @height || obj.posY < 0

  start: ->
    @createAlienWave()
    setInterval( =>
      @createAlienWave()
    , 2000)
    @loop()

  loop: ->
    @bindFireKey()
    @timer = setInterval(@update, 1000 / @FPS)

  checkUserMovement: ->
    @hero.image = @hero.straightImage
    if key.isPressed('left')
      @hero.move(-1)
      @hero.image = @hero.leftImage
    if key.isPressed('right')
      @hero.move( 1)
      @hero.image = @hero.rightImage

  bindFireKey: ->
    key 'space', => @hero.fire()

class Ship
  constructor: (@posX, @posY) ->
    @exploded = false
    @explosionImages = _.times(6, (i) ->
      document.getElementById("explosion#{i + 1}")
    )
    @width = 75
    @height = 50

  draw: (ctx) ->
    if not @exploded
      width = 75
      height = 50
      ctx.drawImage(@image, @posX - width / 2, @posY - height / 2, width, height)
    else
      ctx.drawImage(@image, @posX - 15, @posY - 25)

  explode: (ctx) ->
    @exploded = true
    @image = @explosionImages[0]
    i = 1
    timer = setInterval( =>
      clearInterval(timer) if i >= @explosionImages.length - 1
      @image = @explosionImages[i]
      i++
    , 100)

  isHit: (obj) ->
    @distanceTo(obj) < 30

  distanceTo: (obj) ->
    Math.pow(Math.pow(@posX - obj.posX, 2) + Math.pow(@posY - obj.posY, 2), 0.5)

class Alien extends Ship
  constructor: (@posX, @posY) ->
    super(@posX, @posY)
    @image = document.getElementById('xwing')
    @velocity = {x: 0, y: 1}
    setInterval( =>
      @velocity.x = Math.random() * 10 - 5
    , 300)

  update: ->
    @posX += @velocity.x
    @posY += @velocity.y


class Hero extends Ship
  constructor: (@posX, @posY) ->
    super(@posX, @posY)
    @bullets = []
    @speed = 8

    @image = document.getElementById('tiefighter')
    @straightImage = document.getElementById('tiefighter')
    @leftImage = document.getElementById('left-tiefighter')
    @rightImage = document.getElementById('right-tiefighter')

  move: (dir) ->
    @posX += if dir == 1 then @speed else -@speed

  fire: ->
    @bullets.push(new Bullet(@posX, @posY, 'up'))

class Bullet
  constructor: (@posX, @posY, @dir) ->
    @color = 'red'
    @size = 30
    @speed = 10

  draw: (ctx) ->
    ctx.beginPath()
    ctx.moveTo(@posX, @posY)
    ctx.lineTo(@posX, @posY - @size)
    ctx.strokeStyle = @color
    ctx.stroke()
    ctx.closePath()

  update: ->
    if @dir = 'up'
      @posY -= @speed
    else
      @posY += @speed


width = document.body.clientWidth - 100
height = document.body.clientHeight - 100
canvas = document.getElementById('game')
canvas.setAttribute('width', width)
canvas.setAttribute('height', height)
game = new Game(canvas)
game.start()
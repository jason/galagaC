class Game
  constructor: (@canvas) ->
    @ctx = @canvas.getContext('2d')
    @width = @canvas.width
    @height = @canvas.height
    @ship = new Ship(@canvas.width / 2, @height - 40)
    @FPS = 60
    @aliens = []

  update: =>
    @checkMovement()
    @createAliens()
    bullet.update() for bullet in @ship.bullets
    alien.update() for alien in @aliens
    @removeOffScreenBullets()
    @draw()

  draw: ->
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
    @ship.draw(@ctx)
    bullet.draw(@ctx) for bullet in @ship.bullets
    alien.draw(@ctx) for alien in @aliens

  createAliens: ->
    @aliens.push(new Alien(100, 100)) for i in [0..1]

  removeOffScreenBullets: ->
    offScreen = []
    for bullet in @ship.bullets
      if bullet.posX > @width || bullet.posX < 0 || bullet.posY > @height || bullet.posY < 0
        offScreen.push(bullet)
    @ship.bullets = _.difference(@ship.bullets, offScreen)

  loop: ->
    @bindFireKey()
    @timer = setInterval(@update, 1000 / @FPS)

  checkMovement: ->
    @ship.move(-1)  if key.isPressed('left')
    @ship.move( 1)  if key.isPressed('right')

  bindFireKey: ->
    key 'space', => @ship.fire()

class Alien
  constructor: (@posX, @posY) ->
    @size = 20

  draw: (ctx) ->
    wingColor = "rgb(255, 255, 255)"
    bodyColor = "rgb(255, 0, 0)"
    bodyLength = 60
    bodyWidth = 10
    gunColor = "rgb(255, 0, 0)"
    gunLength = 30

    # wings
    wingspan = 55
    wingHeight = 15
    ctx.beginPath()
    ctx.fillStyle = wingColor
    ctx.fillRect(@posX - wingspan / 2, @posY, wingspan, wingHeight)
    ctx.closePath()

    # body
    ctx.beginPath()
    ctx.moveTo(@posX - bodyWidth, @posY)
    ctx.lineTo(@posX, @posY + bodyLength)
    ctx.lineTo(@posX + bodyWidth, @posY)
    ctx.fillStyle = bodyColor
    ctx.fill()
    ctx.closePath()

    # guns
    gunWidth = 5
    ctx.fillStyle = gunColor
    ctx.beginPath()
    ctx.fillRect(@posX + wingspan / 2, @posY, gunWidth, gunLength)
    ctx.fillRect(@posX - wingspan / 2, @posY, gunWidth, gunLength)

    ctx.fill()
    ctx.closePath()

  update: ->

class Ship
  constructor: (@posX, @posY) ->
    @size = 20
    @color = "rgb(125, 125, 125)"
    @bullets = []
    @speed = 8

  move: (dir) ->
    @posX += if dir == 1 then @speed else -@speed

  fire: ->
    @bullets.push(new Bullet(@posX, @posY - @size))

  draw: (ctx) ->
    ctx.beginPath()
    ctx.arc(@posX, @posY, @size, 0, 2 * Math.PI, true)
    ctx.fillStyle = @color
    ctx.fill()
    ctx.closePath()

    ctx.beginPath()
    ctx.lineWidth = 5

    # Connectors
    connectorSize = 10
    ctx.moveTo(@posX + @size, @posY)
    ctx.lineTo(@posX + @size + connectorSize, @posY)
    ctx.moveTo(@posX - @size, @posY)
    ctx.lineTo(@posX - @size - connectorSize, @posY)

    # Wings
    wingSize = 25
    ctx.moveTo(@posX + @size + connectorSize, @posY - wingSize)
    ctx.lineTo(@posX + @size + connectorSize, @posY + wingSize)
    ctx.moveTo(@posX - @size - connectorSize, @posY - wingSize)
    ctx.lineTo(@posX - @size - connectorSize, @posY + wingSize)

    ctx.strokeStyle = @color
    ctx.stroke()
    ctx.closePath()

class Bullet
  constructor: (@posX, @posY) ->
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
    @posY -= @speed



canvas = document.getElementById('game')
game = new Game(canvas)
game.loop()
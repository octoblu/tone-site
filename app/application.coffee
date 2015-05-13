guid = ->
  s4 = ->
    Math.floor((1 + Math.random()) * 0x10000).toString(16).substring 1

  s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4()


class SoundDevice
  constructor: (options) ->
    @type = options.type
    @uuid = options.uuid
    @synth = @createDevice options

  createDevice: (options) =>
    klass = Tone[@type]
    console.log "Create #{@type} with #{options.initOptions}"
    obj = new klass options.initOptions...
    obj?.toMaster()
    obj?.start?()
    obj

  update: (options) =>
    @[options.action]? options

  attack: (options) =>
    _.each options.notes, (note) =>
      @synth.triggerAttack note, Tone.Transport.now()

  release: (options) =>
    @synth.triggerRelease Tone.Transport.now()

  attackWithRelease: (options) =>
    _.each options.notes, (note) =>
      @synth.triggerAttackRelease note.note, note.duration, Tone.Transport.now()

  frequency: (options) =>
    @synth.frequency.value = options.frequency
    unless options.skipTimeout
      Tone.Transport.setTimeout =>
        @synth.stop()
      , 1

  width: (options) =>
    @synth.width.value = options.width

  start: =>
    @synth.start()

  stop: =>
    @synth.stop()

synth1 = null
synth2 = null
devices = {}

$ ->
  Tone.Transport.start()

  config =
    server: 'wss://meshblu.octoblu.com'
    port: 443
    type: 'device:tone'
    uuid: '450dfe26-8261-4ecd-822e-2ece073e5ca8'
    token: 'b810ff4dcb79530a34660b08eea575f1c82f3619'

  conn = meshblu.createConnection config

  conn.on 'ready', =>
    toneDevice = _.extend
                  uuid: conn.options.uuid
                  token: conn.options.token
                  , config
    console.log 'Device Config', toneDevice

    $(".meshblu-uuid").text toneDevice.uuid
    $(".meshblu-token").text toneDevice.token

    synth1 = new Tone.MonoSynth()
    synth1.toMaster()
    synth2 = new Tone.MonoSynth()
    synth2.toMaster()

    synth1.triggerAttackRelease("G3", "4n", Tone.Transport.now());
    synth2.triggerAttackRelease("E3", "4n", Tone.Transport.now());

    Tone.Transport.setTimeout =>
      synth1.triggerAttackRelease("E3", "2n", Tone.Transport.now());
      synth2.triggerAttackRelease("C3", "2n", Tone.Transport.now());
    , '8n'

  getOrCreateDevice = (options) =>
    options?.uuid ?= guid()
    devices[options.uuid] ?= new SoundDevice options
    devices[options.uuid]

  conn.on 'message', (message) =>
    console.log 'message', message
    payload = message.payload
    device = getOrCreateDevice payload

    if message.topic == 'start'
      device?.start()
      return

    if message.topic == 'stop'
      device?.stop()
      return

    if message.topic == 'update'
      device?.update payload
      return

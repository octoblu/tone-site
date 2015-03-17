config =
  server: 'meshblu.octoblu.com'
  port:   80
  type:   'device:tone'
  uuid:   '17f87030-cc38-11e4-b66b-a374617a4125'
  token:  '7dfc1544a258ddacb1adb825681b9fd12e5548fa'

class Sound
  constructor: ->
    @synths = {}

  attack: (notes) =>
    _.each notes, (note, synthKey) =>
      synth = @synth synthKey
      return unless synth?
      synth.triggerAttack note, Tone.Transport.now()

  release: (options) =>
    synth = @synth(options.synth)
    return unless synth?
    synth.triggerRelease Tone.Transport.now()

  synth: (name) =>
    return @synths[name] if @synths[name]?

    synth = new Tone.MonoSynth()
    synth.toMaster()
    @synths[name] = synth
    synth

$ ->
  sound = new Sound

  Tone.Transport.start()

  conn = meshblu.createConnection config
  conn.on 'ready', =>
    console.log conn
    console.log config

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

    conn.on 'message', (message) =>
      sound[message.topic]?(message.payload)


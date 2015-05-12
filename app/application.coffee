

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

  if $.cookie 'meshblu-tone'
    config = JSON.parse $.cookie 'meshblu-tone'
  else
    config =
      server: 'wss://meshblu.octoblu.com'
      port: 443
      type: 'device:tone'

  conn = meshblu.createConnection config

  conn.on 'ready', =>
    toneDevice = _.extend
                  uuid: conn.options.uuid
                  token: conn.options.token
                  , config
    console.log 'Device Config', toneDevice

    $.cookie 'meshblu-tone', JSON.stringify toneDevice

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

    conn.on 'message', (message) =>
      if (message.topic === 'set-property') {
        synth1[message.payload.property] = message.payload.value;
        synth2[message.payload.property] = message.payload.value;
        return;
      }
      sound[message.topic]?(message.payload)


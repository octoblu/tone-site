meshblu_uuid = '50fc4fc3-12c0-48c2-82ed-6eac9052acc9'
meshblu_token = 'f58db94b792816fc7b046c44acdd9a7f835fd45e'

SAMPLES = [{
  name : 'kick',
  sampleUrl : '/sounds/kick.wav'
},
{
  name : 'bass',
  sampleUrl : '/sounds/bass/bass.wav'
},
{
  name : 'clap',
  sampleUrl : '/sounds/clap.wav'
},
{
  name : 'cymbal',
  sampleUrl : '/sounds/cymbal.wav'
},

{
  name : 'hi hat',
  sampleUrl : '/sounds/hi hat.wav'
},
{
  name : 'snare',
  sampleUrl : '/sounds/snare.wav'
},
{
  name : 'tom',
  sampleUrl : '/sounds/tom.wav'
}]

class Drumkit
  constructor: (samples) ->
    @drumMachines = {}
    _.each samples, (drumConfig) =>
      console.log 'setting up', drumConfig.name
      @drumMachines[drumConfig.name] = @setupDrum drumConfig

  play: (drumName) =>
    drum = @drumMachines[drumName]
    return unless drum?

    drum.play()

  setupDrum: (drumConfig) =>
    return new Howl {
      urls: [drumConfig.sampleUrl],
      volume: 1,
      buffer: false,
      onend: ->
        console.log 'played', drumConfig.name

      onload: ->
        console.log 'loaded', drumConfig.name
    }

$ ->
  drumkit = new Drumkit SAMPLES
  config =
    uuid: meshblu_uuid
    token: meshblu_token
    server: 'wss://meshblu.octoblu.com'
    port: 443
    type: 'device:drumkit'

  conn = meshblu.createConnection config
  window.conn = conn
  window.drumkit = drumkit
  conn.subscribe meshblu_uuid
  conn.on 'ready', =>
    drumkitDevice = _.extend
                  uuid: conn.options.uuid
                  token: conn.options.token
                  , config

    console.log 'Device Config', drumkitDevice
    #
    # $.cookie 'meshblu-drumkit', JSON.stringify drumkitDevice
    # #
    # # $(".meshblu-uuid").text drumkitDevice.uuid
    # # $(".meshblu-token").text drumkitDevice.token

    conn.on 'message', (message) =>
      console.log 'message', message
      if message.topic == 'set-property'
        drumkit[message.payload.property] = message.payload.value;
        return

      drumkit[message.topic]?(message.payload.sound)

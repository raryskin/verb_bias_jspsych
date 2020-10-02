/*
 * Example plugin template
 */

jsPsych.plugins["vwp-click"] = (function() {

  var plugin = {};

//  jsPsych.pluginAPI.registerPreload('vwp-click', 'stimulus', 'audio');

  plugin.info = {
    name: "vwp-click",
    parameters: {
      picTL: {
        type: jsPsych.plugins.parameterType.HTML_STRING, // BOOL, STRING, INT, FLOAT, FUNCTION, KEYCODE, SELECT, HTML_STRING, IMAGE, AUDIO, VIDEO, OBJECT, COMPLEX
        default: undefined
      },
      picTR: {
        type: jsPsych.plugins.parameterType.HTML_STRING, // BOOL, STRING, INT, FLOAT, FUNCTION, KEYCODE, SELECT, HTML_STRING, IMAGE, AUDIO, VIDEO, OBJECT, COMPLEX
        default: undefined
      },
      picBL: {
        type: jsPsych.plugins.parameterType.HTML_STRING, // BOOL, STRING, INT, FLOAT, FUNCTION, KEYCODE, SELECT, HTML_STRING, IMAGE, AUDIO, VIDEO, OBJECT, COMPLEX
        default: undefined
      },
      picBR: {
        type: jsPsych.plugins.parameterType.HTML_STRING, // BOOL, STRING, INT, FLOAT, FUNCTION, KEYCODE, SELECT, HTML_STRING, IMAGE, AUDIO, VIDEO, OBJECT, COMPLEX
        default: undefined
      },
      audio_stim: {
				type: jsPsych.plugins.parameterType.AUDIO,
        pretty_name: 'Audio',
				default: undefined,
				description: 'The audio to be played.'
			},
      choices: {
        type: jsPsych.plugins.parameterType.KEYCODE,
        array: true,
        pretty_name: 'Choices',
        default: jsPsych.ALL_KEYS,
        description: 'The keys the subject is allowed to press to respond to the stimulus.'
      },
      response_ends_trial: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Response ends trial',
        default: true,
        description: 'If true, trial will end when subject makes a response.'
      }
    }
  }

  plugin.trial = function(display_element, trial) {

    // setup stimulus
    var context = jsPsych.pluginAPI.audioContext();
    console.log(context);
    if(context !== null){
      var source = context.createBufferSource();
      source.buffer = jsPsych.pluginAPI.getAudioBuffer(trial.audio_stim);
      source.connect(context.destination);
    } else {
      var audio = jsPsych.pluginAPI.getAudioBuffer(trial.audio_stim);
      audio.currentTime = 0;
    }


    // display stimulus
    var html = "<div><span id='picTL' data-choice='TL' style='position: absolute; top: 10px; width: 48.5%; height: 48%; left: 10px; border: 2px solid black;'><img src='"+
    trial.picTL + "' style='vertical-align:middle;margin:50px 0px;'> </span><span id='picTR' data-choice='TR' style='position: absolute; top: 10px; width: 48.5%; height: 48%; right: 10px; border: 2px solid black;'><img src='"+
    trial.picTR + "' style='vertical-align:middle;margin:50px 0px;'></span><span id='picBL' data-choice='BL' style='position: absolute; bottom: 10px; width: 48.5%; height: 48%; left: 10px; border: 2px solid black;'><img src='"+
    trial.picBL + "' style='vertical-align:middle;margin:50px 0px;'></span><span id='picBR' data-choice='BR' style='position: absolute; bottom: 10px; width: 48.5%; height: 48%; right: 10px; border: 2px solid black;'><img src='"+
    trial.picBR + "' style='vertical-align:middle;margin:50px 0px;'></span></div>";

    console.log(html);
    // render
    display_element.innerHTML = html;

    // start timing
    var start_time = performance.now();

    display_element.querySelector('#picTL').addEventListener('click', function(e){
      var choice = e.currentTarget.getAttribute('data-choice'); // don't use dataset for jsdom compatibility
      after_response(choice);
    });

    display_element.querySelector('#picTR').addEventListener('click', function(e){
      var choice = e.currentTarget.getAttribute('data-choice'); // don't use dataset for jsdom compatibility
      after_response(choice);
    });

    display_element.querySelector('#picBL').addEventListener('click', function(e){
      var choice = e.currentTarget.getAttribute('data-choice'); // don't use dataset for jsdom compatibility
      after_response(choice);
    });

    display_element.querySelector('#picBR').addEventListener('click', function(e){
      var choice = e.currentTarget.getAttribute('data-choice'); // don't use dataset for jsdom compatibility
      after_response(choice);
    });

    // store response
    var response = {
      rt: null,
      clicked_on: null
    };


    function after_response(choice) {

      // measure rt
      var end_time = performance.now();
      var rt = end_time - start_time;
      response.clicked_on = choice;
      response.rt = rt;


      if (trial.response_ends_trial) {
        end_trial();
      }
    };

    // function to end trial when it is time
    function end_trial() {

      // stop the audio file if it is playing
			// remove end event listeners if they exist
			if(context !== null){
				source.stop();
				source.onended = function() { }
			} else {
				audio.pause();
				audio.removeEventListener('ended', end_trial);
			}

      // kill any remaining setTimeout handlers
      jsPsych.pluginAPI.clearAllTimeouts();

        // gather the data to store for the trial
      var trial_data = {
        "visual_stimulus": trial.visual_stimulus,
        "rt": response.rt,
        //"stimulus": trial.stimulus,
        "clicked_on": response.clicked_on
      };

      // clear the display
      display_element.innerHTML = '';

      // end trial
      jsPsych.finishTrial(trial_data);
    };

    var keyboardListener = jsPsych.pluginAPI.getKeyboardResponse({
      callback_function: end_trial,
      valid_responses: trial.choices,
      rt_method: 'performance',
      persist: false,
      allow_held_key: false
    });


    // start time
    var start_time = performance.now();

    // start audio
    if(context !== null){
      startTime = context.currentTime;
      source.start(startTime);
    } else {
      audio.play();
    };


  };

  return plugin;
})();

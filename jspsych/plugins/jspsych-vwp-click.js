/*
 * Example plugin template
 */

jsPsych.plugins["vwp-click"] = (function() {

  var plugin = {};

//  jsPsych.pluginAPI.registerPreload('vwp-click', 'stimulus', 'audio');

  plugin.info = {
    name: "vwp-click",
    parameters: {
  /*    picTL: {
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
      },*/
      pic1: {
        type: jsPsych.plugins.parameterType.HTML_STRING, // BOOL, STRING, INT, FLOAT, FUNCTION, KEYCODE, SELECT, HTML_STRING, IMAGE, AUDIO, VIDEO, OBJECT, COMPLEX
        default: undefined
      },
      pic2: {
        type: jsPsych.plugins.parameterType.HTML_STRING, // BOOL, STRING, INT, FLOAT, FUNCTION, KEYCODE, SELECT, HTML_STRING, IMAGE, AUDIO, VIDEO, OBJECT, COMPLEX
        default: undefined
      },
      pic3: {
        type: jsPsych.plugins.parameterType.HTML_STRING, // BOOL, STRING, INT, FLOAT, FUNCTION, KEYCODE, SELECT, HTML_STRING, IMAGE, AUDIO, VIDEO, OBJECT, COMPLEX
        default: undefined
      },
      pic4: {
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
      delay: {
        type: jsPsych.plugins.parameterType.INT,
        //array: true,
        pretty_name: 'preview time',
        default: 0,
        description: 'The delay in milliseconds between onset of pictures and onset of audio.'
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
    console.log(trial.audio_stim);
    // setup stimulus
    var context = jsPsych.pluginAPI.audioContext();
    //console.log(context);
    if(context !== null){
      var source = context.createBufferSource();
      source.buffer = jsPsych.pluginAPI.getAudioBuffer(trial.audio_stim);
      source.connect(context.destination);
    } else {
      var audio = jsPsych.pluginAPI.getAudioBuffer(trial.audio_stim);
    //  console.log(audio);
      audio.currentTime = 0;
    }

    var all_pics = [trial.pic1, trial.pic2, trial.pic3, trial.pic4];
    console.log(all_pics);

    var shuffled_pics = _.shuffle(all_pics);
    console.log(shuffled_pics);

    var picTL = shuffled_pics[0];
    var picTR = shuffled_pics[1];
    var picBL = shuffled_pics[2];
    var picBR = shuffled_pics[3];

    // display stimulus
    var html = "<div><span id='picTL' data-choice='TL' style='position: absolute; top: 10px; width: 48.5%; height: 48%; left: 10px; border: 2px solid black;'><img src='"+
    picTL + "' style='vertical-align:middle;margin:50px 0px;'> </span><span id='picTR' data-choice='TR' style='position: absolute; top: 10px; width: 48.5%; height: 48%; right: 10px; border: 2px solid black;'><img src='"+
    picTR + "' style='vertical-align:middle;margin:50px 0px;'></span><span id='picBL' data-choice='BL' style='position: absolute; bottom: 10px; width: 48.5%; height: 48%; left: 10px; border: 2px solid black;'><img src='"+
    picBL + "' style='vertical-align:middle;margin:50px 0px;'></span><span id='picBR' data-choice='BR' style='position: absolute; bottom: 10px; width: 48.5%; height: 48%; right: 10px; border: 2px solid black;'><img src='"+
    picBR + "' style='vertical-align:middle;margin:50px 0px;'></span></div>";

    console.log(html);
    // render
    display_element.innerHTML = html;


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



    if (trial.delay > 0) {
      jsPsych.pluginAPI.setTimeout(function() {
        // start audio
        if(context !== null){
          startTime = context.currentTime;
          source.start(startTime);
        } else {
          audio.play();
          console.log(audio);
        };

      }, trial.delay);
      // start timing
      var start_time = performance.now();

    } else {// start audio
      if(context !== null){
        startTime = context.currentTime;
        source.start(startTime);
      } else {
        audio.play();
        console.log(audio);
      };
      // start timing
      var start_time = performance.now();

    }

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
        "picTL": picTL,
        "picTR": picTR,
        "picBL": picBL,
        "picBR": picBR,
        "rt": response.rt,
        "audio_stim": trial.audio_stim,
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


  };

  return plugin;
})();

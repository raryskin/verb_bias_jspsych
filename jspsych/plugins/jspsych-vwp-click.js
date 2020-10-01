/*
 * Example plugin template
 */

jsPsych.plugins["vwp-click"] = (function() {

  var plugin = {};

//  jsPsych.pluginAPI.registerPreload('vwp-click', 'stimulus', 'audio');

  plugin.info = {
    name: "vwp-click",
    parameters: {
      visual_stimulus: {
        type: jsPsych.plugins.parameterType.HTML_STRING, // BOOL, STRING, INT, FLOAT, FUNCTION, KEYCODE, SELECT, HTML_STRING, IMAGE, AUDIO, VIDEO, OBJECT, COMPLEX
        default: undefined
      },
      parameter_name: {
        type: jsPsych.plugins.parameterType.IMAGE,
        default: undefined
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

    // display stimulus
    var html = '<div><img src="'+trial.visual_stimulus+'" id="bloop" data-choice="duckling"></div>';
    console.log(html);
    // render
    display_element.innerHTML = html;

    // start timing
    var start_time = performance.now();

    display_element.querySelector('#bloop').addEventListener('click', function(e){
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

      // kill any remaining setTimeout handlers
      jsPsych.pluginAPI.clearAllTimeouts();

        // gather the data to store for the trial
      var trial_data = {
        "visual_stimulus": trial.visual_stimulus,
        "rt": response.rt,
        //"stimulus": trial.stimulus,
        "clicked_on": response.clicked_on
      };

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
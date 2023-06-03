# Provides:
#   timer
#   automation
#   script

# Needs:
#  sensor.zigbee_btn1_click
#  notify.signal_home
let
  button = "sensor.zigbee_btn2_click";
  notify = "notify.signal_home";
  # für {{ _intent.siteId }} - name of the rhasspy instance: arbeitszimmer
in
{
  services.home-assistant.config = {
    automation = [];
    timer.kurzzeitwecker = {
      name = "Wecker Wohnung";
    };
    timer.wecker_arbeitszimmer = {
      name = "Wecker Arbeitszimmer";
    };
    timer.wecker_wohnzimmer = {
      name = "Wecker Wohnzimmer";
    };
    intent = {};
    intent_script = {
      TimerjobStart = {
        speech.text = ''
          {% set h = hours|default('0')|string %}
          {% set m = minutes|default('0')|string %}
          {% if h == "0" %}
          Wecker  gestellt {{ m }} Minuten
          {% elif m == "0" %}
          Wecker gestellt {{ h }} Stunden
          {% else %}
          Wecker gestellt {{ h }} Stunden und {{ m }} Minuten
          {% endif %}
        '';
        action = [
          {
            service = "timer.start";
            
            data.entity_id = "timer.kurzzeitwecker";
            data.duration = ''
              {% set h = hours|default("0")|int %}
              {% set m = minutes|default("0")|int %}
              {{ "%02d" | format(h) }}:{{ "%02d" | format(m) }}:00
            '';

          }
        ];
      };
      TimerjobRemaining = {
        speech.text = ''
          {% set timer = states('timer.kurzzeitwecker') %}
          {% if timer == 'idle' %}
          Wecker läuft nicht
          {% elif timer == 'active' %}
            {% set remaining = as_timestamp( state_attr('timer.kurzzeitwecker','finishes_at') )-(  as_timestamp(now()))   %}
            {% set s = ((remaining % 60)) | int %}
            {% set m = ((remaining % 3600) / 60) | int %}
            {% set h = ((remaining % 86400) / 3600) | int %}
            {% if h == 0 %}
              Es verbleiben {{ m }} Minuten und {{ s }} Sekunden
            {% elif m == 0 %}
              Es verbleiben {{ h }} Stunden
            {% elif m == 0 and h == 0 %}
              Es verbleiben {{ s }} Sekunden
            {% else %}
              Es verbleiben {{ h }} Stunden {{ m }} Minuten
            {% endif %}
          {% endif %}
        '';
      };
      TimerjobStop = {
        speech.text = ''
          Wecker gestoppt
        '';
        action = [
          { service = "timer.cancel";
            data.entity_id = "timer.kurzzeitwecker";
          }
        ];
      };
    };
  };
}

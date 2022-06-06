{ lib, ...}:
# cycle through scenes

# cycle through color palettes
# {% set options = state_attr('select.wled_color_palette','options') -%}
# {% set selection = options.index(states('select.wled_color_palette'))  -%}
# {% if false -%}
#   {% if (selection + 1) >= options | length -%}
#     {{ options[0] }}
#   {% else -%}
#     {{ options[selection + 1] }}
#   {% endif %}
# {% elif true -%}
#    {{ options[selection -1] }}
# {% endif -%}

let
  # Solid Pattern
  # Hult
  group_id_1 = 16388;
  group_id_2 = 16389;
  group_id_3 = 16390;
  remote = "sensor.schlafzimmer_remote1_action";
  main_light_1 = "light.wled";
  default_scene_1 = "Solid";
  default_color_1 = "Default";
  main_color_select_1 = "select.wled_color_palette";
  light_group_1.entity_id = [ 
      main_light_1
    ];

  # contains only the actually changeable lights 
  light_group_2 = { entity_id = [
    "light.wohnzimmer_komode_osram"
    "light.wohnzimmer_schrank_osram"
    "light.wohnzimmer_fenster_lichterkette_licht"
    ];
  };
  light_group_3 = { entity_id = [
    "light.wohnzimmer_stehlampe_osram"
  ]; };

  statecond = cond: { # cond must be a list
    condition = "template";
    value_template = "{{ trigger.to_state.attributes.action in ( " +
      (lib.concatMapStringsSep "," (x: "'${x}'") cond) + ") }}";
  };
in {
  services.home-assistant.config.automation = [
    {
      alias = "Perform Actions with ${remote}";
      mode = "queued";
      max = 5;
      max_exceeded = "silent";
      trigger = {
        platform = "state";
        entity_id = remote;
      };
      condition = {
        condition = "and";
        conditions = [
          {
            condition = "template";
            value_template =  "{{ trigger.from_state.state != trigger.to_state.state }}";
          }
          ( statecond [ "off" "on" "color_wheel"
          "brightness_up_click" "brightness_down_click"
          "color_temp"  "color_temperature_move"
          "brightness_step_down" "brightness_step_up" "brightness_down_hold" "brightness_down_release" "brightness_up_hold" "brightness_up_release" 
          "scene_3" "scene_1" "scene_2" # working sunset party
          "scene_6" "scene_4" "scene_5" # night campfire romantic
        ])
        ];
      };
      action = [
        { service = "system_log.write";
          data = {
            level = "info";
            message = "Tint Button pressed: {{ trigger.to_state.state }} Group: {{ trigger.to_state.attributes.action_group }} Length {{ input_working_scene_1 | length }}";
          };
        }
        {
          choose = [
            { # light group 1
              conditions = {
                condition = "template";
                value_template = "{{ trigger.to_state.attributes.action_group == ${toString group_id_1} }}";
              };
              sequence = [
                {
                  choose = [
                    {
                      conditions = statecond [ "on" "off" ];
                      sequence = {
                        service = "light.turn_{{ trigger.to_state.state }}";
                        target = light_group_1;
                      };
                    }
                    {
                      conditions = statecond [ "color_wheel" ];
                      sequence = {
                        data.xy_color = [
                          "{{ trigger.to_state.attributes.action_color.x | float }}"
                          "{{ trigger.to_state.attributes.action_color.y | float }}"
                        ];
                        service = "light.turn_on";
                        target = light_group_1;
                      };
                    }
                    {
                      conditions = statecond [ "color_temp" ];
                      sequence = {
                        data.color_temp = "{{ trigger.to_state.attributes.action_color_temperature | float }}";
                        service = "light.turn_on";
                        target = light_group_1;
                      };
                    }
                    {
                      conditions = statecond [ "brightness_up_click" "brightness_down_click" ];
                      sequence = [
                        {
                          variables.factor = ''{% if trigger.to_state.state in ( "brightness_down_click") %} -12 {% else %} 12 {% endif %}'';
                        }
                        {
                          data.brightness_step_pct = "{{ factor | int }}";
                          service = "light.turn_on";
                          target = light_group_1;
                        }
                      ];
                    }
                    {
                      conditions = statecond [
                        "scene_3" # working => previous scene
                        "scene_1" # sunset => default scene (solid)
                        "scene_2" # party => next scene

                      ];
                      sequence = [
                        {
                          data.effect = ''
                            {% set options = state_attr("${main_light_1}","effect_list") -%}
                            {% set selection = options.index(state_attr("${main_light_1}","effect"))  -%}
                            {% if trigger.to_state.attributes.action == "scene_2" -%}
                              {% if (selection + 1) >= options | length -%}
                                {{ options[0] }}
                              {% else -%}
                                {{ options[selection + 1] }}
                              {% endif %}
                            {% elif trigger.to_state.attributes.action == "scene_1" -%}
                              ${default_scene_1}
                            {% elif trigger.to_state.attributes.action == "scene_3" -%}
                              {{ options[selection - 1] }}
                            {% endif -%}
                          '';
                          service = "light.turn_on";
                          target.entity_id = main_light_1;
                        }
                      ];
                    }
                    {
                      conditions = statecond [
                        "scene_6" # night => previous color
                        "scene_4" # campfire => default Color (Default)
                        "scene_5" # romance => next color

                      ];
                      sequence = [
                        {
                          data.option = ''
                            {% set options = state_attr("${main_color_select_1}","options") -%}
                            {% set selection = options.index(states("${main_color_select_1}"))  -%}
                            {% if trigger.to_state.attributes.action == "scene_5" -%}
                              {% if (selection + 1) >= options | length -%}
                                {{ options[0] }}
                              {% else -%}
                                {{ options[selection + 1] }}
                              {% endif %}
                            {% elif trigger.to_state.attributes.action == "scene_4" -%}
                              ${default_color_1}
                            {% elif trigger.to_state.attributes.action == "scene_6" -%}
                              {{ options[selection - 1] }}
                            {% endif -%}
                          '';
                          service = "select.select_option";
                          target.entity_id = main_color_select_1;
                        }
                      ];
                    }
                  ];
                }
              ];
            }
            { # light group 2
              conditions = {
                condition = "template";
                value_template = "{{ trigger.to_state.attributes.action_group == ${toString group_id_2} }}";
              };
              sequence = [
                {
                  choose = [
                    { conditions = statecond [ "on" "off" ];
                      sequence = {
                        service = "light.turn_{{ trigger.to_state.state }}";
                        target = light_group_2;
                      };
                    }
                    {
                      conditions = statecond [ "color_wheel" ];
                      sequence = {
                        data.xy_color = [
                          "{{ trigger.to_state.attributes.action_color.x | float }}"
                          "{{ trigger.to_state.attributes.action_color.y | float }}"
                        ];
                        service = "light.turn_on";
                        target = light_group_2;
                      };
                    }
                    {
                      conditions = statecond [ "color_temp" ];
                      sequence = {
                        data.color_temp = "{{ trigger.to_state.attributes.action_color_temperature | float }}";
                        service = "light.turn_on";
                        target = light_group_2;
                      };
                    }
                    {
                      conditions = statecond [ "brightness_up_click" "brightness_down_click" ];
                      sequence = [
                        {
                          variables.factor = ''{% if trigger.to_state.state in ( "brightness_down_click") %} -12 {% else %} 12 {% endif %}'';
                        }
                        {
                          data.brightness_step_pct = "{{ factor | int }}";
                          service = "light.turn_on";
                          target = light_group_2;
                        }
                      ];
                    }
                  ];
                }
              ];
            }
            { # light group 3
              conditions = {
                condition = "template";
                value_template = "{{ trigger.to_state.attributes.action_group == ${toString group_id_3} }}";
              };
              sequence = [
                {
                  choose = [
                    { conditions = statecond [ "on" "off" ];
                      sequence = {
                        service = "light.turn_{{ trigger.to_state.state }}";
                        target = light_group_3;
                      };
                    }
                    {
                      conditions = statecond [ "color_wheel" ];
                      sequence = {
                        data.xy_color = [
                          "{{ trigger.to_state.attributes.action_color.x | float }}"
                          "{{ trigger.to_state.attributes.action_color.y | float }}"
                        ];
                        service = "light.turn_on";
                        target = light_group_3;
                      };
                    }
                    {
                      conditions = statecond [ "color_temperature_move" ];
                      sequence = {
                        data.color_temp = "{{ trigger.to_state.attributes.action_color_temperature | float }}";
                        service = "light.turn_on";
                        target = light_group_3;
                      };
                    }
                    {
                      conditions = statecond [ "brightness_up_click" "brightness_down_click" ];
                      sequence = [
                        {
                          variables.factor = ''{% if trigger.to_state.state in ( "brightness_down_click") %} -12 {% else %} 12 {% endif %}'';
                        }
                        {
                          data.brightness_step_pct = "{{ factor | int }}";
                          service = "light.turn_on";
                          target = light_group_3;
                        }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    }
  ];
}

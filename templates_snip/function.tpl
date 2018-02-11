/**
 * ${1:{{name}}}{{?func: vmustache#InitCounter("vars", 1)}}
 *{{#parameters}}
 * @param ${{{?func: vmustache#IncrementCounter("vars")}}:{{type}}{{^type}}mixed{{/type}}} ${{name}}${{{?func: vmustache#IncrementCounter("vars")}}}{{/parameters}}
 *
 * @return ${{{?func: vmustache#IncrementCounter("vars")}}:{{return_type}}{{^return_type}}mixed{{/return_type}}}
 */

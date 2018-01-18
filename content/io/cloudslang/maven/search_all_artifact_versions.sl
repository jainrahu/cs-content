#   (c) Copyright 2017 EntIT Software LLC, a Micro Focus company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
########################################################################################################################
#!!
#! @description: This flow returns a lists with all the artifact versions found in the repository.
#!
#! @input group_id: Name of the group ID in which the artifact is found.
#!                  Default: 'io.cloudslang.content'
#! @input artifact_id: Name of the artifact that you are searching in the Maven repository.
#!                     Default: 'cs-mail'
#! @input url: URL to the maven resource that the REST call is made.
#!             Default: 'http://search.maven.org/solrsearch/select?q=g:group_id+AND+a:artifact_id &core=gav&rows=20&wt=json'
#! @input proxy_host: Optional - Proxy server used to access the Maven repository (if required).
#! @input proxy_port: Optional - Proxy server port.
#!                    Default: '8080'
#! @input proxy_username: Optional - Username used when connecting to the proxy.
#! @input proxy_password: Optional - Proxy server password associated with the <proxy_username> input value.
#!
#! @output output: Full details about the specified artifact.
#! @output status_code: 200 if request completed successfully, others in case something went wrong.
#! @output versions: The versions list for the specified artifact.
#!                   The versions response will be empty ([]) if there is no artifact with that name.
#! @output return_code: '0' if success, '-1' otherwise.
#! @output error_message: If there is an error while trying to retrieve the list of artifact versions.
#!
#! @result SUCCESS: The list of artifact versions was retrieved successfully and return code = '0'.
#! @result FAILURE: There was an error while trying to retrieve the artifact version and return_code is '-1'.
#!!#
########################################################################################################################

namespace: io.cloudslang.maven

imports:
  http: io.cloudslang.base.http
  json: io.cloudslang.base.json

flow:
  name: search_all_artifact_versions

  inputs:
    - group_id:
        default: 'io.cloudslang.content'
    - artifact_id:
        default: 'cs-mail'
    - url:
        default: >
            ${'http://search.maven.org/solrsearch/select?q=g:' + group_id + '+AND+a:' +
            artifact_id + '&core=gav&rows=20&wt=json'}
    - proxy_host:
        required: false
    - proxy_port:
        default: '8080'
        required: false
    - proxy_username:
        required: false
    - proxy_password:
        required: false
        sensitive: true

  workflow:
    - search_artifact:
        do:
          http.http_client_get:
            - url
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
        publish:
          - output: ${return_result}
          - status_code
          - error_message
        navigate:
          - SUCCESS: retrieve_all_artifact_versions
          - FAILURE: FAILURE

    - retrieve_all_artifact_versions:
        do:
          json.json_path_query:
            - json_object: ${output}
            - json_path: 'response.docs.*.id'
        publish:
          - return_result
          - return_code
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE

  outputs:
    - output
    - status_code
    - versions: ${return_result}
    - return_code
    - error_message

  results:
    - SUCCESS
    - FAILURE

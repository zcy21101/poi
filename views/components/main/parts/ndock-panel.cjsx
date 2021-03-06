{ROOT, layout, _, $, $$, React, ReactBootstrap} = window
{resolveTime} = window
{Panel, Table} = ReactBootstrap

NdockPanel = React.createClass
  getInitialState: ->
    docks: [
        name: '未使用'
        countdown: -1
      ,
        name: '未使用'
        countdown: -1
      ,
        name: '未使用'
        countdown: -1
      ,
        name: '未使用'
        countdown: -1
      ,
        name: '未使用'
        countdown: -1
    ]
    notified: []
  handleResponse: (e) ->
    {method, path, body, postBody} = e.detail
    {$ships, _ships} = window
    {docks, notified} = @state
    switch path
      when '/kcsapi/api_port/port'
        for ndock in body.api_ndock
          id = ndock.api_id
          switch ndock.api_state
            when -1
              docks[id] =
                name: '未解锁'
                countdown: -1
            when 0
              docks[id] =
                name: '未使用'
                countdown: -1
              notified[id] = false
            when 1
              idx = _.sortedIndex _ships, {api_id: ndock.api_ship_id}, 'api_id'
              docks[id] =
                name: $ships[_ships[idx].api_ship_id].api_name
                countdown: Math.floor((ndock.api_complete_time - new Date()) / 1000)
        @setState
          docks: docks
  updateCountdown: ->
    {docks, notified} = @state
    for i in [1..4]
      if docks[i].countdown > 0
        docks[i].countdown -= 1
        if docks[i].countdown <= 45 && !notified[i]
          notify "#{docks[i].name} 修复完成"
          notified[i] = true
    @setState
      docks: docks
      notified: notified
  componentDidMount: ->
    window.addEventListener 'game.response', @handleResponse
    setInterval @updateCountdown, 1000
  componentWillUnmount: ->
    window.removeEventListener 'game.response', @handleResponse
    clearInterval @updateCountdown, 1000
  render: ->
    <Panel header="入渠" bsStyle="warning">
      <Table>
        <tbody>
        {
          for i in [1..4]
            <tr key={i}>
              <td>{@state.docks[i].name}</td>
              <td>{resolveTime @state.docks[i].countdown}</td>
            </tr>
        }
        </tbody>
      </Table>
    </Panel>

module.exports = NdockPanel

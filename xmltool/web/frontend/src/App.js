import React, { useEffect, useState } from 'react';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import 'bootstrap/dist/css/bootstrap.min.css';
import './App.css';

import CommandSelect from './components/Select/CommandSelect';
import ClassSelect from './components/Select/ClassSelect';
import RaceSelect from './components/Select/RaceSelect';
import IDInput from './components/TextInput/IDInput';
import AttrInput from './components/TextInput/AttrInput';
import CommandInput from './components/TextInput/CommandInput';
import AreaTree from './components/AreaTree/AreaTree';
import SkillChain from './components/SkillChain/SkillChain';

let interval;

function App() {
  const [selectedKeys, setSelectedKeys] = useState([]);
  const [selectedCommand, setSelectedCommand] = useState(null);
  const [selectedClass, setSelectedClass] = useState(null);
  const [selectedRace, setSelectedRace] = useState(null);

  const fetchLogs = async () => {
    const res = await fetch('/logs');
    return await res.text();
  }

  const setLogs = (data) => {
    if (data === '<br>') {
      return;
    }
    
    const logsElement = document.getElementById('logs');
    logsElement.innerHTML = data;
    logsElement.scrollTop = logsElement.scrollHeight;
  }

  const updateLogs = async () => {
    const data = await fetchLogs();
    setLogs(data);
  };

  const clearLogs = async () => {
    await fetch('/clear', {
      method: 'POST',
    });

    const logsElement = document.getElementById('logs');
    logsElement.innerHTML = '';
  }

  const handleSubmit = async (event) => {
    event.preventDefault();
    console.log('Form submitted');
    if (selectedCommand === null) {
      console.error('No command selected');
      return;
    }

    document.getElementById('logs').innerHTML = 'Loading...';
    let json = {};

    if (selectedCommand.value === 'skill' && selectedClass !== null) {
      json = {
        command: selectedCommand.value,
        class: selectedClass.value,
        id: document.getElementById('id-input').value,
        skill_chain: document.getElementById('skill-chain').checked,
        attrs: document.getElementById('attr-input').value,
      };
    } else if (selectedCommand.value === 'area' && selectedKeys.length > 0) {
      json = {
        command: selectedCommand.value,
        area: selectedKeys[0],
        id: document.getElementById('id-input').value,
        attrs: document.getElementById('attr-input').value,
      };
    } else if (selectedCommand.value === 'stats' && selectedClass !== null && selectedRace !== null) {
      json = {
        command: selectedCommand.value,
        class: selectedClass.value,
        race: selectedRace.value,
        attrs: document.getElementById('attr-input').value,
      };
    } else if (selectedCommand.value === 'direct') {
      json = {
        command: selectedCommand.value,
        command_input: document.getElementById('command-input').value,
      };
    }

    if (Object.keys(json).length > 0){
      const resPromise = fetch('/command', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(json),
      });

      interval = setInterval(updateLogs, 100);
      const res = await resPromise;
      const body = await res.text()
      console.log(res.status, body);
      clearInterval(interval);
      updateLogs();
    }
  };

  useEffect(() => {    
    updateLogs();
  }, []);

  return (
    <div id="content">
      <div id="logs-container">
        <div id="header">
          <h3>Minerva XML Tool</h3>
          <div id="clear-button">
            <Button onClick={clearLogs} variant="dark">Clear</Button>
          </div>
        </div>
        <pre id="logs"></pre>
      </div>
      <div id="form-container">
        <Form onSubmit={handleSubmit}>
          <CommandSelect onChange={setSelectedCommand} />
          {selectedCommand && (selectedCommand.value === 'skill' || selectedCommand.value === 'stats')
            && <ClassSelect onChange={setSelectedClass} />}
          {selectedCommand && selectedCommand.value === 'stats'
            && <RaceSelect onChange={setSelectedRace} />}
          {selectedCommand && selectedCommand.value === 'area'
            && <AreaTree onTreeSelect={setSelectedKeys} />}
          {selectedCommand && (selectedCommand.value === 'skill' || selectedCommand.value === 'area')
            && < IDInput />}
          {selectedCommand && selectedCommand.value !== 'direct'
            && <AttrInput />}
          {selectedCommand && selectedCommand.value === 'skill'
            && <SkillChain />}
          {selectedCommand && selectedCommand.value === 'direct'
            && <CommandInput />}
          {selectedCommand && <Button onClick={handleSubmit} variant="dark">Run</Button>}
        </Form>
      </div>
      <img id="mascot" src="elin.png" />
    </div>
  );
}

export default App;
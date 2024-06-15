import React, { useEffect, useState } from 'react';
import Tree from 'rc-tree';
import 'rc-tree/assets/index.css';
import './AreaTree.css';

const AreaTree = ({ onTreeSelect }) => {
  const [treeData, setTreeData] = useState([]);

  const onSelect = (selectedKeys, info) => {
    onTreeSelect(selectedKeys);
  };

  useEffect(() => {
    const fetchAreas = async () => {
      const res = await fetch('/areas');
      const data = await res.json();
      setTreeData(data); // Update treeData with the fetched data
    };

    fetchAreas();
  }, []);

  return (
    <div id="tree-container">
      <Tree
        showLine
        onSelect={onSelect}
        treeData={treeData}
      />
    </div>
  );
};

export default AreaTree;
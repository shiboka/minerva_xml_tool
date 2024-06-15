const selectStyles = {
  menu: (provided, state) => ({
    ...provided,
    backgroundColor: 'black',
    color: 'white',
  }),
  control: (provided, state) => ({
    ...provided,
    backgroundColor: 'black',
    borderColor: '#333',
    color: 'white',
    marginBottom: '10px',
    width: '200px',
  }),
  option: (provided, state) => ({
    ...provided,
    backgroundColor: state.isFocused ? '#111' : 'black',
    color: 'white',
  }),
  singleValue: (provided, state) => ({
    ...provided,
    color: 'white',
  }),
};

export default selectStyles;
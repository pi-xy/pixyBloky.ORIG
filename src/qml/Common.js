function createBlock() {
  var states = ["I", "J", "L", "O", "S", "T", "Z"];
  var i = Math.floor(Math.random() * states.length);
  var state = states[i];

  var component = Qt.createComponent(state + "Block.qml");
  var b = component.createObject(mainStage, {
    x: 720 / 2.0 - (36 * 4) / 2.0,
    y: 36,
    state: state,
  });

  return b;
}

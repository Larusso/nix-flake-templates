{ lockFile, inputName }:
let
  lock = builtins.fromJSON (builtins.readFile lockFile);
  rootInputs = lock.nodes.root.inputs;
  nodeName = rootInputs.${inputName};
  node = lock.nodes.${nodeName};
in
builtins.fetchTree node.locked

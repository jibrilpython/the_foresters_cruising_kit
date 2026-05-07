// ─── CROZE TYPE ──────────────────────────────────────────────────────────────
enum CrozeType {
  handCroze('Hand Croze'),
  castIronCrozePlane('Cast Iron Croze Plane'),
  foldingCroze('Folding Croze'),
  headGroover('Head Groover'),
  chimeCroze('Chime Croze'),
  other('Other');

  const CrozeType(this.label);
  final String label;
}

// ─── BARREL TYPE ─────────────────────────────────────────────────────────────
enum BarrelType {
  whiskey('Whiskey'),
  wine('Wine'),
  beer('Beer'),
  oil('Oil'),
  fish('Fish'),
  pickles('Pickles'),
  gunpowder('Gunpowder'),
  other('Other');

  const BarrelType(this.label);
  final String label;
}

// ─── MANUFACTURING MATERIAL ───────────────────────────────────────────────────
enum ManufacturingMaterial {
  castIron('Cast Iron'),
  wroughtSteel('Wrought Steel'),
  brass('Brass'),
  hardwood('Hardwood Body'),
  mixed('Mixed Materials');

  const ManufacturingMaterial(this.label);
  final String label;
}

// ─── CROZE CONDITION ─────────────────────────────────────────────────────────
enum CrozeCondition {
  pristine('Pristine — Museum Quality'),
  functional('Functional — Working Blade'),
  corroded('Corroded — Surface Rust'),
  dulled('Dulled — Edge Gone'),
  incomplete('Incomplete — Parts Missing'),
  unknown('Unknown');

  const CrozeCondition(this.label);
  final String label;
}

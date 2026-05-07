// ─── TOOL TYPE ───────────────────────────────────────────────────────────────
enum ToolType {
  clinometer('Clinometer'),
  abneyLevel('Abney Level'),
  diameterTape('Diameter Tape'),
  biltmoreStick('Biltmore Stick'),
  incrementBorer('Increment Borer'),
  logRule('Log Rule / Scale Rule'),
  timberScribe('Timber Scribe');

  const ToolType(this.label);
  final String label;
}

// ─── SCALE SYSTEM ─────────────────────────────────────────────────────────────
enum ScaleSystem {
  international('International 1/4"'),
  doyle('Doyle Rule'),
  scribner('Scribner Decimal C'),
  hoppus('Hoppus Measure'),
  biltmore('Biltmore'),
  metric('Metric');

  const ScaleSystem(this.label);
  final String label;
}

// ─── PRIMARY MATERIAL ─────────────────────────────────────────────────────────
enum PrimaryMaterial {
  brass('Brass'),
  forgedSteel('Forged Steel'),
  aluminum('Aluminum'),
  boxwood('Boxwood'),
  hickory('Hickory'),
  canvasTape('Canvas-Reinforced Tape'),
  mixed('Mixed Materials');

  const PrimaryMaterial(this.label);
  final String label;
}

// ─── OPERATING PRINCIPLE ──────────────────────────────────────────────────────
enum OperatingPrinciple {
  mechanical('Mechanical / Gravity'),
  optical('Optical / Rangefinder'),
  directContact('Direct Contact');

  const OperatingPrinciple(this.label);
  final String label;
}

// ─── CONDITION GRADE ──────────────────────────────────────────────────────────
enum ConditionGrade {
  museumQuality('Museum Quality'),
  operational('Operational'),
  wornFunctional('Worn — Functional'),
  corroded('Corroded'),
  incomplete('Incomplete'),
  unknown('Unknown');

  const ConditionGrade(this.label);
  final String label;
}

// ─── TIMBER REGION ────────────────────────────────────────────────────────────
enum TimberRegion {
  pacificNorthwest('Pacific Northwest'),
  appalachian('Appalachian'),
  scandinavian('Scandinavian'),
  britishColumbia('British Columbia'),
  greatLakes('Great Lakes'),
  rockyMountain('Rocky Mountain'),
  southeast('Southeast USA'),
  other('Other / Unknown');

  const TimberRegion(this.label);
  final String label;
}

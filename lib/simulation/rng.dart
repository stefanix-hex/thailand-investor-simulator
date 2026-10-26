class SimRng {
  SimRng(this.state);

  int state;

  int nextInt(int max) {
    state = (1103515245 * state + 12345) & 0x7fffffff;
    return max == 0 ? 0 : state % max;
  }

  double nextDouble() {
    state = (1103515245 * state + 12345) & 0x7fffffff;
    return state / 0x7fffffff;
  }

  double range(double min, double max) => min + (max - min) * nextDouble();

  T pick<T>(List<T> items) => items[nextInt(items.length)];

  bool chance(double p) => nextDouble() < p;
}

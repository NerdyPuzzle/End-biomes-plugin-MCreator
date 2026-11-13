package ${package}.endbiomes;

/** Implemented on {@link Climate.Sampler} by {@code ClimateSamplerMixin}. */
public interface SamplerHooks {
	PerlinNoise getEndBiomesSampler();

	void setSeed(long seed);

	long getSeed();
}
package ${package}.endbiomes;

import com.mojang.logging.LogUtils;
import org.slf4j.Logger;

import java.lang.reflect.Method;

/**
 * Bridge between the copies of this end biomes code that every mod generated with the End biomes plugin ships.
 *
 * <p>All of those mods mix into {@link TheEndBiomeSource} and share one list of {@link TheEndBiomeData.Overrides}
 * (see {@code TheEndBiomeSourceMixin}). Every mod has its own {@code Overrides} class in its own package, so instances
 * that belong to another mod can only be reached through reflection. Instances of this mod's own class are called
 * directly, and the reflective lookups are resolved once per class.</p>
 */
public final class EndBiomesInterop {

	public static final Logger LOGGER = LogUtils.getLogger();

	private static final ClassValue<Contract> CONTRACTS = new ClassValue<>() {
		@Override
		protected Contract computeValue(Class<?> type) {
			try {
				return new Contract(type);
			} catch (ReflectiveOperationException e) {
				throw new IllegalStateException(type.getName() + " does not provide the end biomes overrides API", e);
			}
		}
	};

	private static final AtomicBoolean PICK_FAILED = new AtomicBoolean();
	private static final AtomicBoolean CUSTOM_BIOMES_FAILED = new AtomicBoolean();

	/**
	 * Merges the biomes registered by every other mod into entry 0 (the primary overrides), then builds its pickers.
	 * Must only be called once per biome source.
	 */
	public static void mergeInto(List<? extends Supplier<?>> overrides) {
		if (overrides.isEmpty())
			return;

		Object primary;
		try {
			primary = overrides.get(0).get();
		} catch (RuntimeException e) {
			LOGGER.error("Failed to set up custom end biomes", e);
			return;
		}

		for (Supplier<?> supplier : overrides.subList(1, overrides.size())) {
			Object other = null;
			try {
				other = supplier.get();
				addExternalModBiomes(primary, sharedBiomes(other, 0), "end");
				addExternalModBiomes(primary, sharedBiomes(other, 1), "midlands");
				addExternalModBiomes(primary, sharedBiomes(other, 2), "barrens");
			} catch (ReflectiveOperationException | RuntimeException e) {
				LOGGER.error("Failed to add the custom end biomes of {}", other == null ? "another mod" : other.getClass().getName(), e);
			}
		}

		try {
			if (primary instanceof TheEndBiomeData.Overrides own)
				own.initBiomes();
			else
				CONTRACTS.get(primary.getClass()).initBiomes.invoke(primary);
		} catch (ReflectiveOperationException | RuntimeException e) {
			LOGGER.error("Failed to set up custom end biomes", e);
		}
	}

	/** Picks the end biome to generate, using the primary overrides. Returns {@code biome} if there is nothing to pick from. */
	@SuppressWarnings("unchecked")
	public static Holder<Biome> pick(List<? extends Supplier<?>> overrides, int x, int y, int z, Climate.Sampler noise, Holder<Biome> biome) {
		if (overrides.isEmpty())
			return biome;

		try {
			Object primary = overrides.get(0).get();
			if (primary instanceof TheEndBiomeData.Overrides own)
				return own.pick(x, y, z, noise, biome);
			return (Holder<Biome>) CONTRACTS.get(primary.getClass()).pick.invoke(primary, x, y, z, noise, biome);
		} catch (ReflectiveOperationException | RuntimeException e) {
			if (PICK_FAILED.compareAndSet(false, true))
				LOGGER.error("Failed to pick a custom end biome, keeping the original one", e);
			return biome;
		}
	}

	/** Returns {@code biomes} plus the custom biomes of every mod. */
	@SuppressWarnings("unchecked")
	public static Set<Holder<Biome>> withCustomBiomes(List<? extends Supplier<?>> overrides, Set<Holder<Biome>> biomes) {
		try {
			Set<Holder<Biome>> modifiedBiomes = new LinkedHashSet<>(biomes);
			for (Supplier<?> supplier : overrides) {
				Object override = supplier.get();
				if (override instanceof TheEndBiomeData.Overrides own)
					modifiedBiomes.addAll(own.customBiomes);
				else
					modifiedBiomes.addAll((Set<Holder<Biome>>) CONTRACTS.get(override.getClass()).customBiomes.get(override));
			}
			return Collections.unmodifiableSet(modifiedBiomes);
		} catch (ReflectiveOperationException | RuntimeException e) {
			if (CUSTOM_BIOMES_FAILED.compareAndSet(false, true))
				LOGGER.error("Failed to add custom end biomes to the possible biomes", e);
			return biomes;
		}
	}

	@SuppressWarnings("unchecked")
	private static List<List<Object>> sharedBiomes(Object overrides, int list) throws ReflectiveOperationException {
		if (overrides instanceof TheEndBiomeData.Overrides own)
			return list == 0 ? own.endBiomesCopy : list == 1 ? own.midlandsBiomesCopy : own.barrensBiomesCopy;
		return (List<List<Object>>) CONTRACTS.get(overrides.getClass()).sharedBiomes[list].get(overrides);
	}

	private static void addExternalModBiomes(Object primary, List<List<Object>> biomes, String type) throws ReflectiveOperationException {
		if (primary instanceof TheEndBiomeData.Overrides own)
			own.addExternalModBiomes(biomes, type);
		else
			CONTRACTS.get(primary.getClass()).addExternalModBiomes.invoke(primary, biomes, type);
	}

	/** Reflective handles to the overrides API of one mod's {@code TheEndBiomeData.Overrides} class. */
	private static final class Contract {
		private final Field[] sharedBiomes;
		private final Field customBiomes;
		private final Method addExternalModBiomes;
		private final Method initBiomes;
		private final Method pick;

		private Contract(Class<?> type) throws ReflectiveOperationException {
			sharedBiomes = new Field[] { type.getField("endBiomesCopy"), type.getField("midlandsBiomesCopy"), type.getField("barrensBiomesCopy") };
			customBiomes = type.getField("customBiomes");
			addExternalModBiomes = type.getMethod("addExternalModBiomes", List.class, String.class);
			initBiomes = type.getMethod("initBiomes");
			pick = type.getMethod("pick", int.class, int.class, int.class, Climate.Sampler.class, Holder.class);
		}
	}

}
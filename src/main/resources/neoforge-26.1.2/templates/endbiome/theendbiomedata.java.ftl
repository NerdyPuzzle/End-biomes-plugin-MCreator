package ${package}.endbiomes;

import com.google.common.base.Preconditions;

import javax.annotation.Nullable;

/**
 * Internal data for modding Vanilla's {@link TheEndBiomeSource}.
 */
public final class TheEndBiomeData {
	public static final ThreadLocal<HolderGetter<Biome>> biomeRegistry = new ThreadLocal<>();
	public static final Set<ResourceKey<Biome>> ADDED_BIOMES = new HashSet<>();
	private static final Map<ResourceKey<Biome>, WeightedPicker<ResourceKey<Biome>>> END_BIOMES_MAP = new IdentityHashMap<>();
	private static final Map<ResourceKey<Biome>, WeightedPicker<ResourceKey<Biome>>> END_MIDLANDS_MAP = new IdentityHashMap<>();
	private static final Map<ResourceKey<Biome>, WeightedPicker<ResourceKey<Biome>>> END_BARRENS_MAP = new IdentityHashMap<>();

	// Biomes registered through TheEndBiomes, in the format shared with other mods (see EndBiomesInterop)
	public static List<List<Object>> endBiomes = new ArrayList<>();
	public static List<List<Object>> midlandsBiomes = new ArrayList<>();
	public static List<List<Object>> barrensBiomes = new ArrayList<>();

	static {
		END_BIOMES_MAP.computeIfAbsent(Biomes.THE_END, key -> new WeightedPicker<>()).add(Biomes.THE_END, 1.0);
		END_BIOMES_MAP.computeIfAbsent(Biomes.END_HIGHLANDS, key -> new WeightedPicker<>()).add(Biomes.END_HIGHLANDS, 1.0);
		END_BIOMES_MAP.computeIfAbsent(Biomes.SMALL_END_ISLANDS, key -> new WeightedPicker<>()).add(Biomes.SMALL_END_ISLANDS, 1.0);

		END_MIDLANDS_MAP.computeIfAbsent(Biomes.END_HIGHLANDS, key -> new WeightedPicker<>()).add(Biomes.END_MIDLANDS, 1.0);
		END_BARRENS_MAP.computeIfAbsent(Biomes.END_HIGHLANDS, key -> new WeightedPicker<>()).add(Biomes.END_BARRENS, 1.0);
	}

	public static void addEndBiomeReplacement(ResourceKey<Biome> replaced, ResourceKey<Biome> variant, double weight) {
		addReplacement(END_BIOMES_MAP, replaced, variant, weight, "replaced");
		ADDED_BIOMES.add(variant);
	}

	public static void addEndMidlandsReplacement(ResourceKey<Biome> highlands, ResourceKey<Biome> midlands, double weight) {
		addReplacement(END_MIDLANDS_MAP, highlands, midlands, weight, "highlands");
		ADDED_BIOMES.add(midlands);
	}

	public static void addEndBarrensReplacement(ResourceKey<Biome> highlands, ResourceKey<Biome> barrens, double weight) {
		addReplacement(END_BARRENS_MAP, highlands, barrens, weight, "highlands");
		ADDED_BIOMES.add(barrens);
	}

	private static void addReplacement(Map<ResourceKey<Biome>, WeightedPicker<ResourceKey<Biome>>> map, ResourceKey<Biome> parent, ResourceKey<Biome> biome,
			double weight, String parentName) {
		Preconditions.checkNotNull(parent, "%s entry is null", parentName);
		Preconditions.checkNotNull(biome, "variant entry is null");
		Preconditions.checkArgument(weight > 0.0, "Weight is less than or equal to 0.0 (got %s)", weight);
		map.computeIfAbsent(parent, key -> new WeightedPicker<>()).add(biome, weight);
	}

	public static Overrides createOverrides(HolderGetter<Biome> biomeRegistry) {
		return new Overrides(biomeRegistry);
	}

	private static Map<ResourceKey<Biome>, WeightedPicker<ResourceKey<Biome>>> copyOf(Map<ResourceKey<Biome>, WeightedPicker<ResourceKey<Biome>>> map) {
		Map<ResourceKey<Biome>, WeightedPicker<ResourceKey<Biome>>> copy = new IdentityHashMap<>();
		map.forEach((key, picker) -> copy.put(key, picker.copy()));
		return copy;
	}

	/**
	 * An instance of this class is attached to each {@link TheEndBiomeSource}. Other mods use the public members marked
	 * below through {@link EndBiomesInterop}.
	 */
	public static class Overrides {
		// Shared with other mods: marks overrides that ignore biome lists they already merged
		public static final int API_VERSION = 2;

		// Shared with other mods: biomes this instance adds to the possible biomes
		public final Set<Holder<Biome>> customBiomes;

		// Shared with other mods: copies of the biomes registered through this mod's TheEndBiomes
		public final List<List<Object>> endBiomesCopy;
		public final List<List<Object>> midlandsBiomesCopy;
		public final List<List<Object>> barrensBiomesCopy;

		// Vanilla entries to compare against
		public final Holder<Biome> endMidlands;
		public final Holder<Biome> endBarrens;
		public final Holder<Biome> endHighlands;

		// Maps where the keys have been resolved to actual entries, built by initBiomes()
		public volatile @Nullable Map<Holder<Biome>, WeightedPicker<Holder<Biome>>> endBiomesMap;
		public volatile @Nullable Map<Holder<Biome>, WeightedPicker<Holder<Biome>>> endMidlandsMap;
		public volatile @Nullable Map<Holder<Biome>, WeightedPicker<Holder<Biome>>> endBarrensMap;

		private final HolderGetter<Biome> biomeRegistryInstance;

		// This instance's own copy of the replacement maps, taken when they are first needed. Biomes of other mods are merged
		// into these rather than into the static maps, so they are never counted twice (by several mods merging, or by
		// re-opening a world).
		private @Nullable Map<ResourceKey<Biome>, WeightedPicker<ResourceKey<Biome>>> endBiomeReplacements;
		private @Nullable Map<ResourceKey<Biome>, WeightedPicker<ResourceKey<Biome>>> midlandsReplacements;
		private @Nullable Map<ResourceKey<Biome>, WeightedPicker<ResourceKey<Biome>>> barrensReplacements;
		private final Set<List<List<Object>>> mergedExternalBiomes = Collections.newSetFromMap(new IdentityHashMap<>());

		public Overrides(HolderGetter<Biome> biomeRegistry) {
			this.customBiomes = ADDED_BIOMES.stream().map(biomeRegistry::getOrThrow).collect(Collectors.toSet());

			this.endMidlands = biomeRegistry.getOrThrow(Biomes.END_MIDLANDS);
			this.endBarrens = biomeRegistry.getOrThrow(Biomes.END_BARRENS);
			this.endHighlands = biomeRegistry.getOrThrow(Biomes.END_HIGHLANDS);

			this.endBiomesCopy = List.copyOf(endBiomes);
			this.midlandsBiomesCopy = List.copyOf(midlandsBiomes);
			this.barrensBiomesCopy = List.copyOf(barrensBiomes);

			this.biomeRegistryInstance = biomeRegistry;
		}

		/** Shared with other mods: adds the biomes another mod registered. Adding the same list again does nothing. */
		@SuppressWarnings("unchecked")
		public synchronized void addExternalModBiomes(List<List<Object>> biomes, String type) {
			copyReplacements();
			Map<ResourceKey<Biome>, WeightedPicker<ResourceKey<Biome>>> replacements = switch (type) {
				case "end" -> endBiomeReplacements;
				case "midlands" -> midlandsReplacements;
				case "barrens" -> barrensReplacements;
				default -> null;
			};
			if (replacements == null || !mergedExternalBiomes.add(biomes))
				return;

			for (List<Object> biome : biomes)
				addReplacement(replacements, (ResourceKey<Biome>) biome.get(0), (ResourceKey<Biome>) biome.get(1), (double) biome.get(2), "parent");
		}

		/** Shared with other mods: (re)builds the pickers, must be called before {@link #pick}. */
		public synchronized void initBiomes() {
			copyReplacements();
			this.endBiomesMap = resolveOverrides(biomeRegistryInstance, endBiomeReplacements, Biomes.THE_END);
			this.endMidlandsMap = resolveOverrides(biomeRegistryInstance, midlandsReplacements, Biomes.END_MIDLANDS);
			this.endBarrensMap = resolveOverrides(biomeRegistryInstance, barrensReplacements, Biomes.END_BARRENS);
		}

		private void copyReplacements() {
			if (endBiomeReplacements == null) {
				endBiomeReplacements = copyOf(END_BIOMES_MAP);
				midlandsReplacements = copyOf(END_MIDLANDS_MAP);
				barrensReplacements = copyOf(END_BARRENS_MAP);
			}
		}

		// Resolves all RegistryKey instances to RegistryEntries
		private @Nullable Map<Holder<Biome>, WeightedPicker<Holder<Biome>>> resolveOverrides(HolderGetter<Biome> biomeRegistry,
				Map<ResourceKey<Biome>, WeightedPicker<ResourceKey<Biome>>> overrides, ResourceKey<Biome> vanillaKey) {
			Map<Holder<Biome>, WeightedPicker<Holder<Biome>>> result = new Object2ObjectOpenCustomHashMap<>(overrides.size(), RegistryKeyHashStrategy.INSTANCE);

			for (Map.Entry<ResourceKey<Biome>, WeightedPicker<ResourceKey<Biome>>> entry : overrides.entrySet()) {
				WeightedPicker<ResourceKey<Biome>> picker = entry.getValue();
				int count = picker.getEntryCount();
				if (count == 0 || (count == 1 && entry.getKey() == vanillaKey))
					continue; // don't use no-op entries, for vanilla key biome check 1 as we have default entry

				result.put(biomeRegistry.getOrThrow(entry.getKey()), picker.map(biomeRegistry::getOrThrow));
			}

			return result.isEmpty() ? null : result;
		}

		/** Shared with other mods: picks the biome to generate instead of {@code vanillaBiome}. */
		public Holder<Biome> pick(int x, int y, int z, Climate.Sampler noise, Holder<Biome> vanillaBiome) {
			boolean isMidlands = vanillaBiome.is(endMidlands::is);

			if (isMidlands || vanillaBiome.is(endBarrens::is)) {
				// select a random highlands biome replacement, then try to replace it with a midlands or barrens biome replacement
				Holder<Biome> highlandsReplacement = pick(endHighlands, endHighlands, endBiomesMap, x, z, noise);
				Map<Holder<Biome>, WeightedPicker<Holder<Biome>>> map = isMidlands ? endMidlandsMap : endBarrensMap;

				return pick(highlandsReplacement, vanillaBiome, map, x, z, noise);
			}

			// vanillaBiome may already have been replaced by another mod's injector, it is then simply kept
			return pick(vanillaBiome, vanillaBiome, endBiomesMap, x, z, noise);
		}

		private <T extends Holder<Biome>> T pick(T key, T defaultValue, @Nullable Map<T, WeightedPicker<T>> pickers, int x, int z, Climate.Sampler noise) {
			if (pickers == null)
				return defaultValue;

			WeightedPicker<T> picker = pickers.get(key);
			if (picker == null)
				return defaultValue;
			int count = picker.getEntryCount();
			if (count == 0 || (count == 1 && key.is(endHighlands::is)))
				return defaultValue;

			// The x and z of the entry are divided by 64 to ensure custom biomes are large enough; going larger than this
			// seems to make custom biomes too hard to find.
			return picker.pickFromNoise(((SamplerHooks) (Object) noise).getEndBiomesSampler(), x / 64.0, 0, z / 64.0);
		}
	}

	enum RegistryKeyHashStrategy implements Hash.Strategy<Holder<?>> {
		INSTANCE;

		@Override
		public boolean equals(Holder<?> a, Holder<?> b) {
			if (a == b)
				return true;
			if (a == null || b == null)
				return false;
			if (a.kind() != b.kind())
				return false;
			// This Optional#get is safe - if a has key, b should also have key
			// given a.getType() != b.getType() check above
			// noinspection OptionalGetWithoutIsPresent
			return a.unwrap().map(key -> b.unwrapKey().get() == key, b.value()::equals);
		}

		@Override
		public int hashCode(Holder<?> a) {
			if (a == null)
				return 0;
			return a.unwrap().map(System::identityHashCode, Object::hashCode);
		}
	}
}
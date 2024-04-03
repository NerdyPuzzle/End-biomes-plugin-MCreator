package ${package}.endbiomes

import net.minecraft.world.level.biome.Biome;

public class BiomeUtils {

    public static class BiomeInitialLayer extends WeightedRandomLayer<WeightedEntry.Wrapper<ResourceKey<Biome>>>
    {
        private final Registry<Biome> biomeRegistry;

        public BiomeInitialLayer(RegistryAccess registryAccess, List<WeightedEntry.Wrapper<ResourceKey<Biome>>> entries)
        {
            super(entries);
            this.biomeRegistry = registryAccess.registryOrThrow(Registry.BIOME_REGISTRY);
        }

        @Override
        protected int getEntryIndex(WeightedEntry.Wrapper<ResourceKey<Biome>> entry)
        {
            return this.resolveId(entry.getData());
        }

        @Override
        protected int getDefaultIndex()
        {
            return this.resolveId(net.minecraft.world.level.biome.Biomes.OCEAN);
        }

        private int resolveId(ResourceKey<Biome> key)
        {
            if (!this.biomeRegistry.containsKey(key))
                throw new RuntimeException("Attempted to resolve id for unregistered biome " + key);

            return this.biomeRegistry.getId(this.biomeRegistry.get(key));
        }
    }

    public static enum ZoomLayer implements AreaTransformer1
    {
        NORMAL,
        FUZZY
        {
            @Override
            protected int modeOrRandom(AreaContext cont, int a, int b, int c, int d)
            {
                return cont.random(a, b, c, d);
            }
        };

        private static final int ZOOM_BITS = 1;
        private static final int ZOOM_MASK = 1;

        public int getParentX(int x)
        {
            return x >> 1;
        }

        public int getParentY(int y)
        {
            return y >> 1;
        }

        @Override
        public int apply(AreaContext context, Area area, int x, int y)
        {
            int i = area.get(this.getParentX(x), this.getParentY(y));
            context.initRandom((long) (x >> 1 << 1), (long) (y >> 1 << 1));
            int j = x & 1;
            int k = y & 1;
            if (j == 0 && k == 0)
            {
                return i;
            }
            else
            {
                int l = area.get(this.getParentX(x), this.getParentY(y + 1));
                int i1 = context.random(i, l);
                if (j == 0 && k == 1)
                {
                    return i1;
                }
                else
                {
                    int j1 = area.get(this.getParentX(x + 1), this.getParentY(y));
                    int k1 = context.random(i, j1);
                    if (j == 1 && k == 0)
                    {
                        return k1;
                    }
                    else
                    {
                        int l1 = area.get(this.getParentX(x + 1), this.getParentY(y + 1));
                        return this.modeOrRandom(context, i, j1, l, l1);
                    }
                }
            }
        }

        protected int modeOrRandom(AreaContext context, int a, int b, int c, int d)
        {
            if (b == c && c == d)
                return b;
            else if (a == b && a == c)
                return a;
            else if (a == b && a == d)
                return a;
            else if (a == c && a == d)
                return a;
            else if (a == b && c != d)
                return a;
            else if (a == c && b != d)
                return a;
            else if (a == d && b != c)
                return a;
            else if (b == c && a != d)
                return b;
            else if (b == d && a != c)
                return b;
            else
                return c == d && a != b ? c : context.random(a, b, c, d);
        }
    }

    public static interface PixelTransformer
    {
        int apply(int x, int y);
    }

    public static interface AreaTransformer1
    {
        default AreaFactory run(AreaContext context, AreaFactory areaFactory)
        {
            return () -> {
                Area area = areaFactory.make();
                return context.createResult((x, y) -> {
                    context.initRandom((long)x, (long)y);
                    return this.apply(context, area, x, y);
                }, area);
            };
        }

        int apply(AreaContext context, Area area, int x, int y);
    }

    public static interface AreaTransformer0
    {
        default AreaFactory run(AreaContext context) {
            return () -> {
                return context.createResult((x, y) -> {
                    context.initRandom((long)x, (long)y);
                    return this.apply(context, x, y);
                });
            };
        }

        int apply(AreaContext context, int x, int y);
    }

    public static interface AreaFactory
    {
        Area make();
    }

    public static class AreaContext
    {
        private static final int MAX_CACHE = 1024;
        private final int maxCache;
        private final long seed;
        private long rval;

        public AreaContext(int maxCache, long worldSeed, long seedModifier) {
            this.seed = mixSeed(worldSeed, seedModifier);
            this.maxCache = maxCache;
        }

        public Area createResult(PixelTransformer transformer)
        {
            return new Area(transformer, this.maxCache);
        }

        public Area createResult(PixelTransformer p_76541_, Area p_76542_)
        {
            return new Area(p_76541_, Math.min(MAX_CACHE, p_76542_.getMaxCache() * 4));
        }

        public Area createResult(PixelTransformer transformer, Area p_76545_, Area p_76546_) {
            return new Area(transformer, Math.min(MAX_CACHE, Math.max(p_76545_.getMaxCache(), p_76546_.getMaxCache()) * 4));
        }

        public void initRandom(long x, long y)
        {
            long i = this.seed;
            i = LinearCongruentialGenerator.next(i, x);
            i = LinearCongruentialGenerator.next(i, y);
            i = LinearCongruentialGenerator.next(i, x);
            i = LinearCongruentialGenerator.next(i, y);
            this.rval = i;
        }

        public int nextRandom(int bound)
        {
            int i = Math.floorMod(this.rval >> 24, bound);
            this.rval = LinearCongruentialGenerator.next(this.rval, this.seed);
            return i;
        }

        public int random(int a, int b)
        {
            return this.nextRandom(2) == 0 ? a : b;
        }

        public int random(int a, int b, int c, int d)
        {
            int i = this.nextRandom(4);
            if (i == 0) {
                return a;
            } else if (i == 1) {
                return b;
            } else {
                return i == 2 ? c : d;
            }
        }

        private static long mixSeed(long worldSeed, long seedModifier)
        {
            long i = LinearCongruentialGenerator.next(seedModifier, seedModifier);
            i = LinearCongruentialGenerator.next(i, seedModifier);
            i = LinearCongruentialGenerator.next(i, seedModifier);
            long j = LinearCongruentialGenerator.next(worldSeed, i);
            j = LinearCongruentialGenerator.next(j, i);
            return LinearCongruentialGenerator.next(j, i);
        }
    }

    public static class Area
    {
        private final long[] keys;
        private final int[] values;
        private final int mask;
        private final PixelTransformer operator;
        private final StampedLock lock = new StampedLock();

        public Area(PixelTransformer operator, int size)
        {
            this.operator = operator;

            size = Mth.smallestEncompassingPowerOfTwo(size);
            this.mask = size - 1;

            this.keys = new long[size];
            Arrays.fill(this.keys, Long.MIN_VALUE);
            this.values = new int[size];
        }

        public int get(int x, int z)
        {
            long key = key(x, z);
            int idx = hash(key) & this.mask;
            long stamp = this.lock.readLock();

            // if the entry here has a key that matches ours, we have a cache hit
            if (this.keys[idx] == key) {
                int value = this.values[idx];
                this.lock.unlockRead(stamp);

                return value;
            } else {
                // cache miss: sample and put the result into our cache entry
                this.lock.unlockRead(stamp);

                stamp = this.lock.writeLock();

                int value = this.operator.apply(x, z);
                this.keys[idx] = key;
                this.values[idx] = value;

                this.lock.unlockWrite(stamp);

                return value;
            }
        }

        private int hash(long key) {
            return (int) HashCommon.mix(key);
        }

        private long key(int x, int z)
        {
            return ChunkPos.asLong(x, z);
        }

        public int getMaxCache()
        {
            return this.mask + 1;
        }
    }

    public static class WeightedRandomList<E extends WeightedEntry>
    {
        private final int totalWeight;
        private final ImmutableList<E> items;

        WeightedRandomList(List<? extends E> items)
        {
            this.items = ImmutableList.copyOf(items);
            this.totalWeight = WeightedRandom.getTotalWeight(items);
        }

        public static <E extends WeightedEntry> WeightedRandomList<E> create()
        {
            return new WeightedRandomList<>(ImmutableList.of());
        }

        public static <E extends WeightedEntry> WeightedRandomList<E> create(E... entries)
        {
            return new WeightedRandomList<>(ImmutableList.copyOf(entries));
        }

        public static <E extends WeightedEntry> WeightedRandomList<E> create(List<E> entries)
        {
            return new WeightedRandomList<>(entries);
        }

        public Optional<E> getRandom(AreaContext context)
        {
            if (this.totalWeight == 0) {
                return Optional.empty();
            } else {
                int i = context.nextRandom(this.totalWeight);
                return WeightedRandom.getWeightedItem(this.items, i);
            }
        }
    }

    public abstract static class WeightedRandomLayer<T extends WeightedEntry> implements AreaTransformer0
    {
        private final WeightedRandomList<T> weightedEntries;

        public WeightedRandomLayer(List<T> entries)
        {
            this.weightedEntries = WeightedRandomList.create(entries);
        }

        @Override
        public int apply(AreaContext context, int x, int y)
        {
            return this.weightedEntries.getRandom(context).map(this::getEntryIndex).orElse(getDefaultIndex());
        }

        protected abstract int getEntryIndex(T entry);

        protected int getDefaultIndex()
        {
            return 0;
        }
    }

    public static class LayerUtil {

        public static Area biomeArea(RegistryAccess registryAccess, long seed, int size, List<WeightedEntry.Wrapper<ResourceKey<Biome>>> entries)
        {
            return createZoomedArea(seed, size, new BiomeInitialLayer(registryAccess, entries));
        }

        public static Area createZoomedArea(long seed, int zooms, AreaTransformer0 initialTransformer)
        {
            LongFunction<AreaContext> contextFactory = (seedModifier) -> new AreaContext(25, seed, seedModifier);
            AreaFactory factory = initialTransformer.run(contextFactory.apply(1L));
            factory = ZoomLayer.FUZZY.run(contextFactory.apply(2000L), factory);
            factory = zoom(2001L, ZoomLayer.NORMAL, factory, 3, contextFactory);
            factory = zoom(1001L, ZoomLayer.NORMAL, factory, zooms, contextFactory);
            return factory.make();
        }

        public static AreaFactory zoom(long seedModifier, AreaTransformer1 transformer, AreaFactory initialAreaFactory, int times, LongFunction<AreaContext> contextFactory)
        {
            AreaFactory areaFactory = initialAreaFactory;

            for (int i = 0; i < times; ++i)
            {
                areaFactory = transformer.run(contextFactory.apply(seedModifier + (long)i), areaFactory);
            }

            return areaFactory;
        }
    }

}
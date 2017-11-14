APP = hw5
CLASSPATH = $(shell hadoop classpath)
BUILDDIR = build
SRCDIR = src
SOURCES = $(wildcard $(SRCDIR)/*.java)
CLASSES = $(patsubst $(SRCDIR)/%.java,$(BUILDDIR)/%.class,$(SOURCES))
MAIN_CLASS = WordCount
HDFS_INDIR = hdfs:/user/$(USER)/$(APP)/input
HDFS_OUTDIR = hdfs:/user/$(USER)/$(APP)/output
LOCAL_INDIR = input
LOCAL_OUTDIR = output
JC = javac
JFLAGS = -cp $(CLASSPATH) -d $(BUILDDIR)
JAR = jar
JARFLAGS = cvf $(APP).jar -C $(BUILDDIR)/ .
MKDIR_P = mkdir -p
HDFS_MKDIR_P = hdfs dfs -mkdir -p
HDFS_CP_FROM_LOCAL = hdfs dfs -copyFromLocal -f
HDFS_CP_TO_LOCAL = hdfs dfs -copyToLocal
HDFS_RM_R = hdfs dfs -rm -r -f
OUTFILE = part-r-00000

.PHONY: clean hdfs run test

all: $(APP).jar

$(APP).jar: $(CLASSES)
	$(JAR) $(JARFLAGS)

$(CLASSES): $(SOURCES)
	$(MKDIR_P) $(BUILDDIR)
	$(JC) $(JFLAGS) $<

hdfs:
	$(HDFS_MKDIR_P) $(HDFS_INDIR) && \
		$(HDFS_CP_FROM_LOCAL) $(LOCAL_INDIR)/* $(HDFS_INDIR)/ && \
		$(HDFS_RM_R) $(HDFS_OUTDIR)

run: $(APP).jar hdfs
	hadoop jar $(APP).jar $(MAIN_CLASS) $(HDFS_INDIR) $(HDFS_OUTDIR) && \
		$(RM) -r $(LOCAL_OUTDIR) && \
		$(MKDIR_P) $(LOCAL_OUTDIR) && \
		$(HDFS_CP_TO_LOCAL) $(HDFS_OUTDIR) .

clean:
	$(RM) *.jar
	$(RM) $(BUILDDIR)/*
	$(RM) $(LOCAL_OUTDIR)/*
	hdfs dfs -rm -r -f $(HDFS_INDIR)
	hdfs dfs -rm -r -f $(HDFS_OUTDIR)

test:
	@diff $(LOCAL_OUTDIR)/$(OUTFILE) $(OUTFILE) && echo "Passed." || echo "Failed."

context("completeness")

# CTU05
l_ctu05 <- read_secuTrial(system.file("extdata", "sT_exports", "longnames",
                                      "s_export_CSV-xls_CTU05_long_ref_miss_en_utf8.zip",
                                      package = "secuTrialR"))
s_ctu05 <- read_secuTrial(system.file("extdata", "sT_exports", "shortnames",
                                      "s_export_CSV-xls_CTU05_short_ref_miss_en_utf8.zip",
                                      package = "secuTrialR"))
# polish
s_ctu05_pl <- read_secuTrial(system.file("extdata", "sT_exports", "shortnames",
                                         "s_export_CSV-xls_CTU05_short_meta_ref_miss_pl_utf8.zip",
                                         package = "secuTrialR"))

# TES05
# warning can be suppressed (it is expected)
suppressWarnings(
s_tes05_iso <- read_secuTrial(system.file("extdata", "sT_exports", "encodings",
                                          "s_export_CSV-xls_TES05_short_ref_en_iso8859-15.zip",
                                          package = "secuTrialR"))
)
# warning can be suppressed (it is expected)
suppressWarnings(
l_tes05_utf <- read_secuTrial(system.file("extdata", "sT_exports", "encodings",
                                          "s_export_CSV-xls_TES05_long_ref_en_utf8.zip",
                                          package = "secuTrialR"))
)

test_that("Test fail", {
  expect_error(form_status_counts(1337))
  expect_error(form_status_counts(c(1, 3, 3, 7)))
})

# long and short cannot match on form_names, so we just check the data columns
cols_counts <- c("pat_id", "completely_filled", "partly_filled", "empty", "with_warnings", "with_errors")

test_that("Test output equality for different export options", {
  expect_equal(form_status_counts(s_ctu05)[, cols_counts], form_status_counts(l_ctu05)[, cols_counts])
  expect_equal(form_status_counts(s_tes05_iso)[, cols_counts], form_status_counts(l_tes05_utf)[, cols_counts])
  # polish vs. english should be the same
  expect_equal(form_status_counts(s_ctu05_pl)[, cols_counts], form_status_counts(l_ctu05)[, cols_counts])
})

test_that("Test column sums", {
  expect_equal(as.vector(colSums(form_status_counts(l_ctu05)[, 3:7])), c(74, 5, 0, 0, 0))
  expect_equal(as.vector(colSums(form_status_counts(s_tes05_iso)[, 3:7])), c(21, 12, 4, 0, 0))
})

# custom count checks
# as manually compared to the secuTrial web interface
counts_for_custom_tests <- form_status_counts(s_tes05_iso)
test_that("Individual entries", {
  # RPACKRIG-USZ-11111 has 4 (1x baseline, 3x fu visit) empty forms and nothing is filled at all
  expect_equal(counts_for_custom_tests[which(counts_for_custom_tests$pat_id == "RPACKRIG-USZ-11111" &
                                  counts_for_custom_tests$form_name == "bl"), ]$empty,
               1)
  expect_equal(counts_for_custom_tests[which(counts_for_custom_tests$pat_id == "RPACKRIG-USZ-11111" &
                                             counts_for_custom_tests$form_name == "fuvisit"), ]$empty,
               3)
  # RPACKRIG-USZ-4 has 1x baseline completely filled,
  #                    3x fu visit completely filled,
  #                    1x fu visit partly filled,
  #                    1x intervals completely filled
  expect_equal(counts_for_custom_tests[which(counts_for_custom_tests$pat_id == "RPACKRIG-USZ-4" &
                                               counts_for_custom_tests$form_name == "bl"), ]$completely_filled,
               1)
  expect_equal(counts_for_custom_tests[which(counts_for_custom_tests$pat_id == "RPACKRIG-USZ-4" &
                                               counts_for_custom_tests$form_name == "fuvisit"), ]$completely_filled,
               3)
  expect_equal(counts_for_custom_tests[which(counts_for_custom_tests$pat_id == "RPACKRIG-USZ-4" &
                                               counts_for_custom_tests$form_name == "fuvisit"), ]$partly_filled,
               1)
  expect_equal(counts_for_custom_tests[which(counts_for_custom_tests$pat_id == "RPACKRIG-USZ-4" &
                                               counts_for_custom_tests$form_name == "intervals"), ]$completely_filled,
               1)
})

test_that("Test that partly, completely and empty percentages add up to 1 i.e. 100%", {
  # the vector is made up of ones subtracting one from all of them and summing should always return 0
  expect_equal(sum(rowSums(subset(form_status_summary(s_ctu05),
                                  select = c("partly_filled.percent",
                                             "completely_filled.percent",
                                             "empty.percent"))) - 1),
               0)
  expect_equal(sum(rowSums(subset(form_status_summary(l_tes05_utf),
                                  select = c("partly_filled.percent",
                                             "completely_filled.percent",
                                             "empty.percent"))) - 1),
               0)
})

cols_summary <- c("partly_filled", "completely_filled", "empty", "with_warnings",
                  "with_errors", "partly_filled.percent", "completely_filled.percent",
                  "empty.percent", "with_warnings.percent", "with_errors.percent", "form_count")

test_that("Test column sums", {
  expect_equal(colSums(form_status_summary(s_ctu05)[, cols_summary]),
               colSums(form_status_summary(l_ctu05)[, cols_summary]))
  expect_equal(round(as.vector(colSums(form_status_summary(l_ctu05)[, cols_summary])), digits = 4),
               c(5, 74, 0, 0, 0, 0.3122, 9.6878, 0, 0, 0, 79))
  expect_equal(colSums(form_status_summary(s_tes05_iso)[, cols_summary]),
               colSums(form_status_summary(l_tes05_utf)[, cols_summary]))
  expect_equal(round(as.vector(colSums(form_status_summary(s_tes05_iso)[, cols_summary])), digits = 4),
               c(12, 21, 4, 0, 0, 2.9774, 2.6798, 0.3429, 0, 0, 37)
               )
  # polish vs. english should be the same
  expect_equal(colSums(form_status_summary(s_ctu05_pl)[, cols_summary]),
               colSums(form_status_summary(l_ctu05)[, cols_summary]))
})

# TODO add more tests with warnings and errors and empty data

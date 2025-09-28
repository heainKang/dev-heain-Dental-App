# frozen_string_literal: true
ActiveAdmin.register_page "Reports" do
  menu priority: 2, label: "📊 신고 처리"

  content title: "신고 및 이슈 관리" do
    # 임시로 간단한 신고 처리 시스템
    columns do
      column do
        panel "🚨 신고 유형별 통계" do
          table_for [
            ["부적절한 구인공고", 5],
            ["사기 의심 병원", 2],
            ["불법 수수료 요구", 3],
            ["허위 정보 제공", 1],
            ["기타", 2]
          ] do |report|
            column("신고 유형") { |r| r[0] }
            column("건수") { |r| strong r[1] }
          end
        end
      end

      column do
        panel "⚠️ 처리 상태" do
          table_for [
            ["처리 대기", 8],
            ["조사 중", 3],
            ["처리 완료", 15],
            ["기각", 2]
          ] do |status|
            column("상태") { |s| s[0] }
            column("건수") { |s| strong s[1] }
          end
        end
      end
    end

    columns do
      column do
        panel "📋 최근 신고 내역" do
          # 실제 구현에서는 Report 모델을 만들어야 함
          table_for [
            ["2025-01-27", "김**", "부적절한 구인공고", "처리 대기"],
            ["2025-01-26", "이**", "사기 의심 병원", "조사 중"],
            ["2025-01-25", "박**", "불법 수수료 요구", "처리 완료"],
            ["2025-01-24", "최**", "허위 정보 제공", "처리 완료"],
            ["2025-01-23", "정**", "기타", "처리 대기"]
          ] do |report|
            column("날짜") { |r| r[0] }
            column("신고자") { |r| r[1] }
            column("신고 유형") { |r| r[2] }
            column("상태") { |r| status_tag r[3] }
            column("액션") { |r| link_to "상세보기", "#", class: "button" }
          end
        end
      end
    end

    columns do
      column do
        panel "📈 월별 신고 현황" do
          div do
            para "이 섹션에는 월별 신고 접수 현황과 처리 통계가 표시됩니다."
            para "실제 환경에서는 차트 라이브러리를 사용하여 시각적으로 표현할 수 있습니다."
          end
          
          table_for [
            ["2025-01", 13, 10, 3],
            ["2024-12", 8, 8, 0],
            ["2024-11", 15, 12, 3],
            ["2024-10", 6, 6, 0]
          ] do |month|
            column("월") { |m| m[0] }
            column("접수") { |m| m[1] }
            column("처리완료") { |m| m[2] }
            column("처리중") { |m| m[3] }
          end
        end
      end

      column do
        panel "🛠️ 관리 기능" do
          div class: "action_items" do
            span class: "action_item" do
              link_to "일괄 처리", "#", class: "button", confirm: "일괄 처리를 진행하시겠습니까?"
            end
            span class: "action_item" do
              link_to "신고 템플릿 관리", "#", class: "button"
            end
            span class: "action_item" do
              link_to "처리 가이드라인", "#", class: "button"
            end
          end
          
          div style: "margin-top: 20px;" do
            h4 "빠른 액션"
            ul do
              li { link_to "새 신고 검토", "#" }
              li { link_to "처리 대기 목록", "#" }
              li { link_to "신고자 관리", "#" }
              li { link_to "처리 통계 내보내기", "#" }
            end
          end
        end
      end
    end
  end
end
